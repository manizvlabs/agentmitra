"""
Data Validator Utility
======================

Utility for validating imported data against business rules and constraints.
"""

import re
from typing import Dict, List, Any, Optional
import logging
from datetime import datetime
import phonenumbers

logger = logging.getLogger(__name__)


class DataValidator:
    """Data validation utility for imported records"""

    def __init__(self):
        # Phone number regex patterns for different countries
        self.phone_patterns = {
            'india': r'^(\+91|91|0)?[6-9]\d{9}$',
            'usa': r'^(\+1|1)?[2-9]\d{2}[2-9]\d{6}$',
        }

        # Email regex pattern
        self.email_pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'

        # Policy number patterns
        self.policy_patterns = {
            'lic': r'^[0-9]{8,12}$',  # LIC policy numbers are typically 8-12 digits
        }

    async def validate_row(self, row_data: Dict[str, Any], import_type: str) -> Dict[str, Any]:
        """Validate a single row of data"""

        errors = []

        if import_type == "customer_data":
            errors.extend(self._validate_customer_data(row_data))
        elif import_type == "policy_data":
            errors.extend(self._validate_policy_data(row_data))

        return {
            "valid": len(errors) == 0,
            "errors": errors
        }

    def _validate_customer_data(self, data: Dict[str, Any]) -> List[str]:
        """Validate customer data"""
        errors = []

        # Validate customer name
        if not data.get('customer_name') or not isinstance(data.get('customer_name'), str):
            errors.append("Customer name is required and must be text")
        elif len(str(data.get('customer_name', '')).strip()) < 2:
            errors.append("Customer name must be at least 2 characters long")

        # Validate phone number
        phone_errors = self._validate_phone_number(data.get('phone_number'))
        errors.extend(phone_errors)

        # Validate email (optional but if provided, must be valid)
        if data.get('email'):
            email_errors = self._validate_email(data.get('email'))
            errors.extend(email_errors)

        # Validate date of birth (optional)
        if data.get('date_of_birth'):
            dob_errors = self._validate_date_of_birth(data.get('date_of_birth'))
            errors.extend(dob_errors)

        # Validate address fields
        address_errors = self._validate_address(data)
        errors.extend(address_errors)

        return errors

    def _validate_policy_data(self, data: Dict[str, Any]) -> List[str]:
        """Validate policy data"""
        errors = []

        # Validate policy number
        if not data.get('policy_number'):
            errors.append("Policy number is required")
        else:
            policy_errors = self._validate_policy_number(data.get('policy_number'))
            errors.extend(policy_errors)

        # Validate premium amount
        if data.get('premium_amount') is not None:
            premium_errors = self._validate_premium_amount(data.get('premium_amount'))
            errors.extend(premium_errors)

        # Validate sum assured
        if data.get('sum_assured') is not None:
            sum_assured_errors = self._validate_sum_assured(data.get('sum_assured'))
            errors.extend(sum_assured_errors)

        # Validate dates
        if data.get('issue_date'):
            date_errors = self._validate_date(data.get('issue_date'), 'issue_date')
            errors.extend(date_errors)

        if data.get('maturity_date'):
            date_errors = self._validate_date(data.get('maturity_date'), 'maturity_date')
            errors.extend(date_errors)

        # Validate policy type
        if data.get('policy_type'):
            type_errors = self._validate_policy_type(data.get('policy_type'))
            errors.extend(type_errors)

        return errors

    def _validate_phone_number(self, phone: Any) -> List[str]:
        """Validate phone number"""
        errors = []

        if not phone:
            errors.append("Phone number is required")
            return errors

        phone_str = str(phone).strip()

        # Remove any spaces, hyphens, etc.
        phone_str = re.sub(r'[^\d+]', '', phone_str)

        # Try to parse as Indian phone number (most common use case)
        try:
            parsed_number = phonenumbers.parse(phone_str, "IN")
            if not phonenumbers.is_valid_number(parsed_number):
                errors.append(f"Invalid phone number format: {phone}")
        except phonenumbers.NumberParseException:
            # Fallback to regex validation
            if not re.match(self.phone_patterns['india'], phone_str):
                errors.append(f"Phone number format not recognized: {phone}")

        return errors

    def _validate_email(self, email: Any) -> List[str]:
        """Validate email address"""
        errors = []

        if not email:
            return errors  # Email is optional

        email_str = str(email).strip()

        if not re.match(self.email_pattern, email_str):
            errors.append(f"Invalid email format: {email}")

        return errors

    def _validate_date_of_birth(self, dob: Any) -> List[str]:
        """Validate date of birth"""
        errors = []

        try:
            if isinstance(dob, str):
                # Try different date formats
                date_formats = ['%Y-%m-%d', '%d/%m/%Y', '%m/%d/%Y', '%d-%m-%Y']
                parsed_date = None

                for fmt in date_formats:
                    try:
                        parsed_date = datetime.strptime(str(dob), fmt)
                        break
                    except ValueError:
                        continue

                if not parsed_date:
                    errors.append(f"Invalid date format for date of birth: {dob}")
                    return errors

            elif isinstance(dob, datetime):
                parsed_date = dob
            else:
                errors.append(f"Date of birth must be a valid date: {dob}")
                return errors

            # Check if person is not too old or too young
            today = datetime.now()
            age = today.year - parsed_date.year - ((today.month, today.day) < (parsed_date.month, parsed_date.day))

            if age < 18:
                errors.append("Customer must be at least 18 years old")
            elif age > 120:
                errors.append("Invalid date of birth - customer cannot be over 120 years old")

        except Exception as e:
            errors.append(f"Error validating date of birth: {str(e)}")

        return errors

    def _validate_address(self, data: Dict[str, Any]) -> List[str]:
        """Validate address fields"""
        errors = []

        # Basic validation for address components
        if data.get('pincode'):
            pincode_str = str(data.get('pincode')).strip()
            if not re.match(r'^\d{6}$', pincode_str):
                errors.append(f"Invalid PIN code format: {data.get('pincode')} (must be 6 digits)")

        # Validate state (optional but if provided, should be reasonable)
        if data.get('state'):
            state_str = str(data.get('state')).strip()
            if len(state_str) < 2:
                errors.append("State name is too short")

        return errors

    def _validate_policy_number(self, policy_number: Any) -> List[str]:
        """Validate policy number"""
        errors = []

        if not policy_number:
            errors.append("Policy number is required")
            return errors

        policy_str = str(policy_number).strip()

        # Check basic format (should be numeric)
        if not re.match(r'^\d+$', policy_str):
            errors.append(f"Policy number should contain only digits: {policy_number}")
            return errors

        # Check length (LIC policies are typically 8-12 digits)
        if not 8 <= len(policy_str) <= 12:
            errors.append(f"Policy number length should be 8-12 digits: {policy_number}")

        return errors

    def _validate_premium_amount(self, amount: Any) -> List[str]:
        """Validate premium amount"""
        errors = []

        try:
            # Try to convert to float
            amount_float = float(amount)

            if amount_float <= 0:
                errors.append(f"Premium amount must be greater than zero: {amount}")
            elif amount_float > 1000000:  # 10 lakhs
                errors.append(f"Premium amount seems too high: {amount} (max expected: 10,00,000)")

        except (ValueError, TypeError):
            errors.append(f"Invalid premium amount format: {amount}")

        return errors

    def _validate_sum_assured(self, amount: Any) -> List[str]:
        """Validate sum assured amount"""
        errors = []

        try:
            amount_float = float(amount)

            if amount_float <= 0:
                errors.append(f"Sum assured must be greater than zero: {amount}")
            elif amount_float > 50000000:  # 5 crores
                errors.append(f"Sum assured seems too high: {amount} (max expected: 5,00,00,000)")

        except (ValueError, TypeError):
            errors.append(f"Invalid sum assured format: {amount}")

        return errors

    def _validate_date(self, date_value: Any, field_name: str) -> List[str]:
        """Validate date field"""
        errors = []

        try:
            if isinstance(date_value, str):
                # Try different date formats
                date_formats = ['%Y-%m-%d', '%d/%m/%Y', '%m/%d/%Y', '%d-%m-%Y']
                parsed_date = None

                for fmt in date_formats:
                    try:
                        parsed_date = datetime.strptime(str(date_value), fmt)
                        break
                    except ValueError:
                        continue

                if not parsed_date:
                    errors.append(f"Invalid date format for {field_name}: {date_value}")

            elif isinstance(date_value, datetime):
                parsed_date = date_value
            else:
                errors.append(f"{field_name} must be a valid date: {date_value}")

        except Exception as e:
            errors.append(f"Error validating {field_name}: {str(e)}")

        return errors

    def _validate_policy_type(self, policy_type: Any) -> List[str]:
        """Validate policy type"""
        errors = []

        if not policy_type:
            return errors  # Policy type is optional

        type_str = str(policy_type).strip()

        # Common LIC policy types
        valid_types = [
            'term', 'endowment', 'money back', 'ulip', 'pension',
            'child', 'health', 'annuity', 'group', 'micro insurance'
        ]

        # Check if it's a known policy type (case insensitive)
        if type_str.lower() not in [t.lower() for t in valid_types]:
            # Don't add error for unknown types - they might be valid
            logger.warning(f"Unknown policy type: {policy_type}")

        return errors

    def validate_bulk_data(self, records: List[Dict[str, Any]], import_type: str) -> Dict[str, Any]:
        """Validate bulk data and return summary"""
        total_records = len(records)
        valid_records = 0
        invalid_records = 0
        all_errors = []

        for i, record in enumerate(records):
            result = self.validate_row(record, import_type)

            if result["valid"]:
                valid_records += 1
            else:
                invalid_records += 1
                all_errors.extend([f"Row {i+1}: {error}" for error in result["errors"]])

        return {
            "total_records": total_records,
            "valid_records": valid_records,
            "invalid_records": invalid_records,
            "errors": all_errors[:100]  # Limit error messages
        }
