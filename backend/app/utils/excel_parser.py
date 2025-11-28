"""
Excel Parser Utility
====================

Utility for parsing Excel files and validating their structure.
"""

import pandas as pd
from typing import Dict, List, Any, Optional
import logging

logger = logging.getLogger(__name__)


class ExcelParser:
    """Excel file parsing utility"""

    def __init__(self):
        self.supported_formats = ['.xlsx', '.xls']

    async def parse_excel(self, file_path: str) -> List[Dict[str, Any]]:
        """Parse Excel file and return list of dictionaries"""
        try:
            # Read Excel file
            df = pd.read_excel(file_path, engine='openpyxl')

            # Convert to list of dictionaries
            records = []
            for _, row in df.iterrows():
                # Convert row to dictionary, handling NaN values
                record = {}
                for col in df.columns:
                    value = row[col]
                    # Convert NaN to None
                    if pd.isna(value):
                        record[col] = None
                    else:
                        record[col] = value

                records.append(record)

            logger.info(f"Successfully parsed {len(records)} records from {file_path}")
            return records

        except Exception as e:
            logger.error(f"Error parsing Excel file {file_path}: {e}")
            raise

    async def validate_structure(self, file_path: str) -> Dict[str, Any]:
        """Validate Excel file structure"""
        try:
            # Read Excel file
            df = pd.read_excel(file_path, engine='openpyxl')

            # Check if file is empty
            if df.empty:
                return {
                    "valid": False,
                    "errors": ["Excel file is empty"]
                }

            # Check for required columns (basic validation)
            required_columns = ["customer_name", "phone_number"]  # Can be configurable
            missing_columns = []

            for col in required_columns:
                if col not in df.columns:
                    missing_columns.append(col)

            if missing_columns:
                return {
                    "valid": False,
                    "errors": [f"Missing required columns: {', '.join(missing_columns)}"]
                }

            # Check for minimum data rows
            if len(df) == 0:
                return {
                    "valid": False,
                    "errors": ["No data rows found in Excel file"]
                }

            return {
                "valid": True,
                "columns": list(df.columns),
                "row_count": len(df),
                "errors": []
            }

        except Exception as e:
            logger.error(f"Error validating Excel structure for {file_path}: {e}")
            return {
                "valid": False,
                "errors": [f"File validation failed: {str(e)}"]
            }

    def get_column_mapping(self, template_config: Dict[str, Any]) -> Dict[str, str]:
        """Get column mapping from template configuration"""
        return template_config.get('column_mapping', {})

    def validate_data_types(self, df: pd.DataFrame, type_requirements: Dict[str, str]) -> List[str]:
        """Validate data types in DataFrame columns"""
        errors = []

        for col, expected_type in type_requirements.items():
            if col not in df.columns:
                continue

            try:
                if expected_type == 'string':
                    # Check if all non-null values are strings
                    non_null_values = df[col].dropna()
                    if not all(isinstance(val, str) for val in non_null_values):
                        errors.append(f"Column '{col}' should contain only text values")

                elif expected_type == 'number':
                    # Try to convert to numeric
                    pd.to_numeric(df[col], errors='coerce')
                    # Check for conversion failures
                    if df[col].isna().any():
                        errors.append(f"Column '{col}' contains invalid numeric values")

                elif expected_type == 'date':
                    # Try to convert to datetime
                    pd.to_datetime(df[col], errors='coerce')
                    # Check for conversion failures
                    if df[col].isna().any():
                        errors.append(f"Column '{col}' contains invalid date values")

            except Exception as e:
                errors.append(f"Error validating column '{col}': {str(e)}")

        return errors

    def clean_data(self, df: pd.DataFrame) -> pd.DataFrame:
        """Clean and normalize data in DataFrame"""
        # Remove completely empty rows
        df = df.dropna(how='all')

        # Trim whitespace from string columns
        for col in df.select_dtypes(include=['object']).columns:
            df[col] = df[col].astype(str).str.strip()

        # Convert empty strings to NaN
        df = df.replace('', pd.NA)

        return df

    def get_summary_stats(self, df: pd.DataFrame) -> Dict[str, Any]:
        """Get summary statistics for the DataFrame"""
        return {
            "total_rows": len(df),
            "total_columns": len(df.columns),
            "columns": list(df.columns),
            "data_types": df.dtypes.astype(str).to_dict(),
            "null_counts": df.isnull().sum().to_dict(),
            "duplicate_rows": df.duplicated().sum()
        }
