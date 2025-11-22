"""
Import API endpoints for data import functionality
"""
from typing import List, Optional, Dict, Any
from fastapi import APIRouter, Depends, File, UploadFile, Form, HTTPException, BackgroundTasks
from fastapi.responses import StreamingResponse
from sqlalchemy.orm import Session
from pydantic import BaseModel, Field
import pandas as pd
import io
import uuid
from datetime import datetime
import json

from app.core.database import get_db
from app.core.auth import get_current_user_context
from app.models.user import User
from sqlalchemy.orm import Session

router = APIRouter(prefix="/import", tags=["import"])

# In-memory storage for demo purposes (replace with database in production)
_import_templates = {}
_import_files = {}
_import_results = {}
_import_history = []

class ImportTemplate(BaseModel):
    id: str
    name: str
    description: str
    entity_type: str
    column_mappings: List[Dict[str, Any]]
    validation_rules: List[Dict[str, Any]]
    created_at: datetime
    updated_at: datetime
    created_by: str

class ColumnMapping(BaseModel):
    source_column: str
    target_field: str
    data_type: str
    required: bool
    default_value: Optional[Any] = None
    transformation: Optional[str] = None

class ValidationRule(BaseModel):
    field: str
    rule: str
    value: Optional[Any] = None
    message: str

class ImportFileResponse(BaseModel):
    id: str
    name: str
    size: int
    type: str
    headers: List[str]
    preview: List[List[Any]]
    upload_time: datetime
    status: str

class ImportResult(BaseModel):
    id: str
    file_id: str
    template_id: Optional[str] = None
    total_rows: int
    valid_rows: int
    invalid_rows: int
    imported_rows: int
    errors: List[Dict[str, Any]]
    status: str
    start_time: datetime
    end_time: Optional[datetime] = None
    duration: Optional[int] = None

# Sample templates
_sample_templates = [
    {
        "id": "template_customers_001",
        "name": "Customer Import Template",
        "description": "Standard template for importing customer data",
        "entity_type": "customers",
        "column_mappings": [
            {"source_column": "Full Name", "target_field": "fullName", "data_type": "string", "required": True},
            {"source_column": "Email", "target_field": "email", "data_type": "email", "required": True},
            {"source_column": "Phone", "target_field": "phone", "data_type": "phone", "required": True},
            {"source_column": "Date of Birth", "target_field": "dateOfBirth", "data_type": "date", "required": False},
            {"source_column": "Gender", "target_field": "gender", "data_type": "string", "required": False},
            {"source_column": "Occupation", "target_field": "occupation", "data_type": "string", "required": False},
            {"source_column": "Annual Income", "target_field": "annualIncome", "data_type": "currency", "required": False},
        ],
        "validation_rules": [
            {"field": "email", "rule": "email", "message": "Invalid email format"},
            {"field": "phone", "rule": "phone", "message": "Invalid phone number format"},
        ],
        "created_at": datetime.now(),
        "updated_at": datetime.now(),
        "created_by": "system"
    },
    {
        "id": "template_policies_001",
        "name": "Policy Import Template",
        "description": "Standard template for importing insurance policies",
        "entity_type": "policies",
        "column_mappings": [
            {"source_column": "Policy Number", "target_field": "policyNumber", "data_type": "string", "required": True},
            {"source_column": "Policy Type", "target_field": "policyType", "data_type": "string", "required": True},
            {"source_column": "Customer Name", "target_field": "customerName", "data_type": "string", "required": True},
            {"source_column": "Start Date", "target_field": "startDate", "data_type": "date", "required": True},
            {"source_column": "End Date", "target_field": "endDate", "data_type": "date", "required": True},
            {"source_column": "Premium Amount", "target_field": "premiumAmount", "data_type": "currency", "required": True},
            {"source_column": "Status", "target_field": "status", "data_type": "string", "required": True},
        ],
        "validation_rules": [
            {"field": "policyNumber", "rule": "required", "message": "Policy number is required"},
            {"field": "startDate", "rule": "required", "message": "Start date is required"},
            {"field": "endDate", "rule": "required", "message": "End date is required"},
        ],
        "created_at": datetime.now(),
        "updated_at": datetime.now(),
        "created_by": "system"
    }
]

# Initialize sample templates
for template in _sample_templates:
    _import_templates[template["id"]] = ImportTemplate(**template)

@router.get("/templates", response_model=List[ImportTemplate])
async def get_templates(current_user = Depends(get_current_user_context)):
    """Get all import templates"""
    return list(_import_templates.values())

@router.post("/templates", response_model=ImportTemplate)
async def create_template(
    template_data: Dict[str, Any],
    current_user = Depends(get_current_user_context)
):
    """Create a new import template"""
    template_id = str(uuid.uuid4())
    template = ImportTemplate(
        id=template_id,
        **template_data,
        created_at=datetime.now(),
        updated_at=datetime.now(),
        created_by=current_user.user.email
    )
    _import_templates[template_id] = template
    return template

@router.put("/templates/{template_id}", response_model=ImportTemplate)
async def update_template(
    template_id: str,
    template_data: Dict[str, Any],
    current_user = Depends(get_current_user_context)
):
    """Update an import template"""
    if template_id not in _import_templates:
        raise HTTPException(status_code=404, detail="Template not found")

    template = _import_templates[template_id]
    for key, value in template_data.items():
        if hasattr(template, key):
            setattr(template, key, value)
    template.updated_at = datetime.now()

    return template

@router.delete("/templates/{template_id}")
async def delete_template(
    template_id: str,
    current_user = Depends(get_current_user_context)
):
    """Delete an import template"""
    if template_id not in _import_templates:
        raise HTTPException(status_code=404, detail="Template not found")

    del _import_templates[template_id]
    return {"message": "Template deleted successfully"}

@router.post("/upload", response_model=ImportFileResponse)
async def upload_file(
    file: UploadFile = File(...),
    options: Optional[str] = Form(None),
    current_user = Depends(get_current_user_context)
):
    """Upload a file for import processing"""
    file_id = str(uuid.uuid4())

    # Parse options
    parsed_options = json.loads(options) if options else {"hasHeaders": True, "skipRows": 0}

    # Read file content
    content = await file.read()
    file_size = len(content)

    # Process file based on type
    if file.filename.endswith('.csv'):
        # Process CSV
        df = pd.read_csv(io.BytesIO(content), **parsed_options)
    elif file.filename.endswith(('.xlsx', '.xls')):
        # Process Excel
        df = pd.read_excel(io.BytesIO(content), **parsed_options)
    else:
        raise HTTPException(status_code=400, detail="Unsupported file type")

    # Convert to data structure
    headers = df.columns.tolist()
    data = df.values.tolist()

    # Create preview (first 5 rows)
    preview = data[:5] if len(data) > 5 else data

    import_file = ImportFileResponse(
        id=file_id,
        name=file.filename,
        size=file_size,
        type=file.content_type,
        headers=headers,
        preview=preview,
        upload_time=datetime.now(),
        status="uploaded"
    )

    _import_files[file_id] = {
        "file": import_file,
        "data": data,
        "headers": headers
    }

    return import_file

@router.post("/validate/{file_id}", response_model=ImportResult)
async def validate_file(
    file_id: str,
    template_id: Optional[str] = None,
    current_user = Depends(get_current_user_context)
):
    """Validate uploaded file data"""
    if file_id not in _import_files:
        raise HTTPException(status_code=404, detail="File not found")

    file_data = _import_files[file_id]
    data = file_data["data"]
    headers = file_data["headers"]

    errors = []
    valid_rows = 0

    # Get validation rules if template specified
    validation_rules = []
    if template_id and template_id in _import_templates:
        template = _import_templates[template_id]
        validation_rules = template.validation_rules

    # Validate each row
    for row_idx, row in enumerate(data):
        row_errors = []
        is_valid = True

        # Check required fields
        for rule in validation_rules:
            if rule["rule"] == "required":
                field_idx = headers.index(rule["field"]) if rule["field"] in headers else -1
                if field_idx >= 0 and (field_idx >= len(row) or not row[field_idx]):
                    row_errors.append({
                        "row": row_idx + 1,
                        "field": rule["field"],
                        "error": rule["message"],
                        "value": row[field_idx] if field_idx < len(row) else None
                    })
                    is_valid = False

        if is_valid:
            valid_rows += 1
        else:
            errors.extend(row_errors)

    result = ImportResult(
        id=str(uuid.uuid4()),
        file_id=file_id,
        template_id=template_id,
        total_rows=len(data),
        valid_rows=valid_rows,
        invalid_rows=len(errors),
        imported_rows=0,
        errors=errors,
        status="validated",
        start_time=datetime.now()
    )

    _import_results[result.id] = result
    return result

@router.post("/data")
async def import_data(
    request: Dict[str, Any],
    background_tasks: BackgroundTasks,
    current_user = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """Import validated data"""
    from app.repositories.policy_repository import PolicyRepository, PolicyholderRepository
    from app.repositories.user_repository import UserRepository

    file_id = request.get("fileId")
    template_id = request.get("templateId")
    entity_type = request.get("entityType", "policies")

    if file_id not in _import_files:
        raise HTTPException(status_code=404, detail="File not found")

    file_data = _import_files[file_id]
    data = file_data["data"]
    headers = file_data["headers"]

    import_id = str(uuid.uuid4())
    start_time = datetime.now()

    try:
        imported_count = 0
        errors = []

        if entity_type == "policies":
            policy_repo = PolicyRepository(db)
            policyholder_repo = PolicyholderRepository(db)

            for row_idx, row in enumerate(data):
                try:
                    # Convert row to dict using headers
                    row_dict = dict(zip(headers, row))

                    # Basic validation and data processing
                    policy_number = row_dict.get("policy_number", "").strip()
                    if not policy_number:
                        errors.append(f"Row {row_idx + 1}: Missing policy number")
                        continue

                    # Check if policy already exists
                    existing_policy = policy_repo.get_by_policy_number(policy_number)
                    if existing_policy:
                        errors.append(f"Row {row_idx + 1}: Policy {policy_number} already exists")
                        continue

                    # Find or create policyholder
                    policyholder_id = row_dict.get("policyholder_id")
                    if not policyholder_id:
                        # Try to find by phone number or create new
                        phone_number = row_dict.get("phone_number", "").strip()
                        if phone_number:
                            user_repo = UserRepository(db)
                            user = user_repo.get_by_phone(phone_number)
                            if user:
                                # Find policyholder for this user
                                policyholder = policyholder_repo.get_by_user_id(str(user.user_id))
                                if policyholder:
                                    policyholder_id = str(policyholder.policyholder_id)
                                else:
                                    # Create new policyholder
                                    policyholder_data = {
                                        "user_id": str(user.user_id),
                                        "phone_number": phone_number,
                                        "first_name": user.first_name,
                                        "last_name": user.last_name,
                                        "email": user.email
                                    }
                                    new_policyholder = policyholder_repo.create(policyholder_data)
                                    policyholder_id = str(new_policyholder.policyholder_id)

                    if not policyholder_id:
                        errors.append(f"Row {row_idx + 1}: Could not find or create policyholder")
                        continue

                    # Create policy data
                    policy_data = {
                        "policy_number": policy_number,
                        "policyholder_id": policyholder_id,
                        "agent_id": current_user.user_id,  # Current user as agent
                        "provider_id": "550e8400-e29b-41d4-a716-446655440000",  # Default provider
                        "policy_type": row_dict.get("policy_type", "term_life"),
                        "plan_name": row_dict.get("plan_name", "Standard Plan"),
                        "premium_amount": float(row_dict.get("premium_amount", 0)),
                        "premium_frequency": row_dict.get("premium_frequency", "monthly"),
                        "sum_assured": float(row_dict.get("sum_assured", 0)),
                        "status": "active"
                    }

                    policy = policy_repo.create(policy_data)
                    imported_count += 1

                except Exception as e:
                    errors.append(f"Row {row_idx + 1}: {str(e)}")

        elif entity_type == "customers":
            # Handle customer import
            user_repo = UserRepository(db)
            policyholder_repo = PolicyholderRepository(db)

            for row_idx, row in enumerate(data):
                try:
                    row_dict = dict(zip(headers, row))

                    phone_number = row_dict.get("phone_number", "").strip()
                    if not phone_number:
                        errors.append(f"Row {row_idx + 1}: Missing phone number")
                        continue

                    # Check if user exists
                    existing_user = user_repo.get_by_phone(phone_number)
                    if existing_user:
                        errors.append(f"Row {row_idx + 1}: User with phone {phone_number} already exists")
                        continue

                    # Create user
                    user_data = {
                        "phone_number": phone_number,
                        "first_name": row_dict.get("first_name", "").strip(),
                        "last_name": row_dict.get("last_name", "").strip(),
                        "email": row_dict.get("email", "").strip(),
                        "role": "policyholder"
                    }

                    user = user_repo.create(user_data)

                    # Create policyholder
                    policyholder_data = {
                        "user_id": str(user.user_id),
                        "phone_number": phone_number,
                        "annual_income": float(row_dict.get("annual_income", 0)),
                        "occupation": row_dict.get("occupation", "").strip()
                    }

                    policyholder_repo.create(policyholder_data)
                    imported_count += 1

                except Exception as e:
                    errors.append(f"Row {row_idx + 1}: {str(e)}")

        end_time = datetime.now()
        duration = int((end_time - start_time).total_seconds() * 1000)

        result = ImportResult(
            id=import_id,
            file_id=file_id,
            template_id=template_id,
            total_rows=len(data),
            valid_rows=len(data) - len(errors),
            invalid_rows=len(errors),
            imported_rows=imported_count,
            errors=errors,
            status="completed",
            start_time=start_time,
            end_time=end_time,
            duration=duration
        )

        _import_results[import_id] = result

    # Add to history
    history_item = {
        "id": import_id,
        "fileName": file_data["file"]["name"],
        "templateName": _import_templates.get(template_id, {}).name if template_id else None,
        "entityType": _import_templates.get(template_id, {}).entity_type if template_id else "unknown",
        "status": "completed",
        "totalRows": len(data),
        "importedRows": len(data),
        "errorCount": 0,
        "startTime": datetime.now(),
        "endTime": datetime.now(),
        "duration": 1000,
        "uploadedBy": current_user.user.email
    }
    _import_history.append(history_item)

    return {
        "importId": import_id,
        "status": "completed",
        "results": result,
        "errors": []
    }

@router.get("/status/{import_id}", response_model=ImportResult)
async def get_import_status(
    import_id: str,
    current_user = Depends(get_current_user_context)
):
    """Get import status"""
    if import_id not in _import_results:
        raise HTTPException(status_code=404, detail="Import not found")

    return _import_results[import_id]

@router.get("/history")
async def get_import_history(
    page: int = 1,
    page_size: int = 10,
    current_user = Depends(get_current_user_context)
):
    """Get import history"""
    start_idx = (page - 1) * page_size
    end_idx = start_idx + page_size

    return {
        "data": _import_history[start_idx:end_idx],
        "total": len(_import_history),
        "page": page,
        "pageSize": page_size,
        "totalPages": (len(_import_history) + page_size - 1) // page_size
    }

@router.get("/entity-fields/{entity_type}")
async def get_entity_fields(
    entity_type: str,
    current_user = Depends(get_current_user_context)
):
    """Get fields for an entity type"""
    # Mock entity field definitions
    entity_fields = {
        "customers": [
            {"name": "fullName", "label": "Full Name", "type": "string", "required": True},
            {"name": "email", "label": "Email", "type": "email", "required": True},
            {"name": "phone", "label": "Phone", "type": "phone", "required": True},
            {"name": "dateOfBirth", "label": "Date of Birth", "type": "date", "required": False},
        ],
        "policies": [
            {"name": "policyNumber", "label": "Policy Number", "type": "string", "required": True},
            {"name": "policyType", "label": "Policy Type", "type": "string", "required": True},
            {"name": "customerName", "label": "Customer Name", "type": "string", "required": True},
            {"name": "premiumAmount", "label": "Premium Amount", "type": "currency", "required": True},
        ]
    }

    return entity_fields.get(entity_type, [])

@router.get("/sample-data/{entity_type}")
async def get_sample_data(
    entity_type: str,
    current_user = Depends(get_current_user_context)
):
    """Get sample data for an entity type"""
    # Mock sample data
    sample_data = {
        "customers": [
            ["John Doe", "john@example.com", "+91-9876543210", "1990-01-15"],
            ["Jane Smith", "jane@example.com", "+91-9876543211", "1985-03-22"],
        ],
        "policies": [
            ["POL001", "Life Insurance", "John Doe", "5000"],
            ["POL002", "Health Insurance", "Jane Smith", "3000"],
        ]
    }

    return sample_data.get(entity_type, [])

@router.get("/templates/{entity_type}/download")
async def download_template(
    entity_type: str,
    current_user = Depends(get_current_user_context)
):
    """Download a template file for an entity type"""
    sample_data = await get_sample_data(entity_type, current_user)

    # Create a simple CSV
    csv_content = ""
    if entity_type == "customers":
        csv_content = "Full Name,Email,Phone,Date of Birth\n" + \
                     "John Doe,john@example.com,+91-9876543210,1990-01-15\n" + \
                     "Jane Smith,jane@example.com,+91-9876543211,1985-03-22\n"
    elif entity_type == "policies":
        csv_content = "Policy Number,Policy Type,Customer Name,Premium Amount\n" + \
                     "POL001,Life Insurance,John Doe,5000\n" + \
                     "POL002,Health Insurance,Jane Smith,3000\n"

    return StreamingResponse(
        io.BytesIO(csv_content.encode()),
        media_type="text/csv",
        headers={"Content-Disposition": f"attachment; filename={entity_type}_template.csv"}
    )

@router.get("/results/{import_id}/download")
async def download_import_results(
    import_id: str,
    current_user = Depends(get_current_user_context)
):
    """Download import results as CSV"""
    if import_id not in _import_results:
        raise HTTPException(status_code=404, detail="Import not found")

    result = _import_results[import_id]

    # Create CSV content with results
    csv_content = "Row,Field,Error,Value\n"
    for error in result.errors:
        csv_content += f"{error['row']},{error.get('field', '')},{error['error']},{error.get('value', '')}\n"

    return StreamingResponse(
        io.BytesIO(csv_content.encode()),
        media_type="text/csv",
        headers={"Content-Disposition": f"attachment; filename=import_results_{import_id}.csv"}
    )
