"""
Insurance Provider repository for shared schema operations
"""
from sqlalchemy.orm import Session
from sqlalchemy import and_, or_
from typing import Optional, List
from app.models.shared import InsuranceProvider
import uuid


class ProviderRepository:
    """Repository for insurance provider operations in shared schema"""

    def __init__(self, db: Session):
        self.db = db

    def get_by_id(self, provider_id) -> Optional[InsuranceProvider]:
        """Get provider by ID (UUID or string)"""
        if isinstance(provider_id, str):
            try:
                provider_id = uuid.UUID(provider_id)
            except ValueError:
                return None
        return self.db.query(InsuranceProvider).filter(InsuranceProvider.provider_id == provider_id).first()

    def get_by_code(self, provider_code: str) -> Optional[InsuranceProvider]:
        """Get provider by provider code"""
        return self.db.query(InsuranceProvider).filter(InsuranceProvider.provider_code == provider_code).first()

    def get_all(self, status: Optional[str] = None) -> List[InsuranceProvider]:
        """Get all providers, optionally filtered by status"""
        query = self.db.query(InsuranceProvider)
        if status:
            query = query.filter(InsuranceProvider.status == status)
        return query.order_by(InsuranceProvider.provider_name).all()

    def search_providers(self, search_term: str, status: Optional[str] = None) -> List[InsuranceProvider]:
        """Search providers by name or code"""
        query = self.db.query(InsuranceProvider).filter(
            or_(
                InsuranceProvider.provider_name.ilike(f"%{search_term}%"),
                InsuranceProvider.provider_code.ilike(f"%{search_term}%")
            )
        )

        if status:
            query = query.filter(InsuranceProvider.status == status)

        return query.order_by(InsuranceProvider.provider_name).all()

    def create(self, provider_data: dict) -> InsuranceProvider:
        """Create a new insurance provider"""
        provider = InsuranceProvider(
            provider_id=uuid.uuid4(),
            provider_code=provider_data.get("provider_code"),
            provider_name=provider_data.get("provider_name"),
            provider_type=provider_data.get("provider_type"),
            description=provider_data.get("description"),
            api_endpoint=provider_data.get("api_endpoint"),
            webhook_url=provider_data.get("webhook_url"),
            license_number=provider_data.get("license_number"),
            regulatory_authority=provider_data.get("regulatory_authority"),
            established_year=provider_data.get("established_year"),
            headquarters=provider_data.get("headquarters"),
            supported_languages=provider_data.get("supported_languages", ["en"]),
            business_hours=provider_data.get("business_hours"),
            service_regions=provider_data.get("service_regions"),
            commission_structure=provider_data.get("commission_structure"),
            status=provider_data.get("status", "active"),
            integration_status=provider_data.get("integration_status", "pending")
        )
        self.db.add(provider)
        self.db.commit()
        self.db.refresh(provider)
        return provider

    def update(self, provider_id, provider_data: dict) -> Optional[InsuranceProvider]:
        """Update provider information"""
        provider = self.get_by_id(provider_id)
        if not provider:
            return None

        # Update fields
        updateable_fields = [
            'provider_name', 'provider_type', 'description', 'api_endpoint',
            'webhook_url', 'license_number', 'regulatory_authority',
            'established_year', 'headquarters', 'supported_languages',
            'business_hours', 'service_regions', 'commission_structure',
            'status', 'integration_status', 'last_sync_at'
        ]

        for field in updateable_fields:
            if field in provider_data:
                setattr(provider, field, provider_data[field])

        self.db.commit()
        self.db.refresh(provider)
        return provider

    def delete(self, provider_id) -> bool:
        """Delete provider (soft delete by setting status to inactive)"""
        provider = self.get_by_id(provider_id)
        if not provider:
            return False

        # Soft delete
        provider.status = 'inactive'
        self.db.commit()
        return True

    def get_active_providers(self) -> List[InsuranceProvider]:
        """Get all active providers"""
        return self.get_all(status='active')

    def get_providers_by_type(self, provider_type: str) -> List[InsuranceProvider]:
        """Get providers by type (life_insurance, health_insurance, etc.)"""
        return self.db.query(InsuranceProvider).filter(
            and_(
                InsuranceProvider.provider_type == provider_type,
                InsuranceProvider.status == 'active'
            )
        ).order_by(InsuranceProvider.provider_name).all()
