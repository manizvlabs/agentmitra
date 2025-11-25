"""
Encryption Service - Multi-tenant encryption service with envelope encryption
Implements data encryption at rest for sensitive tenant data
"""
from cryptography.fernet import Fernet
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC
import base64
import os
import json
from typing import Dict, Any, Optional
import logging
from datetime import datetime, timedelta
from app.core.tenant_service import TenantService

logger = logging.getLogger(__name__)


class EncryptionService:
    """Multi-tenant encryption service using envelope encryption"""

    def __init__(self, tenant_service: TenantService, master_key: Optional[str] = None):
        self.tenant_service = tenant_service
        self.master_key = master_key or os.getenv('ENCRYPTION_MASTER_KEY', self._generate_master_key())
        self._tenant_keys = {}  # Cache for tenant-specific keys
        self._key_cache_ttl = 3600  # 1 hour

    def _generate_master_key(self) -> str:
        """Generate a master key for development (NOT for production)"""
        # WARNING: In production, use a proper KMS service
        return base64.urlsafe_b64encode(os.urandom(32)).decode()

    def encrypt_tenant_data(self, tenant_id: str, data: Dict[str, Any]) -> Dict[str, Any]:
        """Encrypt sensitive data for a tenant"""
        try:
            # Get or create tenant-specific encryption key
            encryption_key = self._get_tenant_encryption_key(tenant_id)

            # Encrypt sensitive fields
            encrypted_data = data.copy()

            sensitive_fields = [
                'ssn', 'bank_account', 'pan_card', 'aadhar_number',
                'medical_history', 'financial_info', 'password',
                'emergency_contact', 'address'
            ]

            for field in sensitive_fields:
                if field in encrypted_data and encrypted_data[field]:
                    encrypted_data[field] = self._encrypt_field(
                        str(encrypted_data[field]), encryption_key
                    )

            return encrypted_data

        except Exception as e:
            logger.error(f"Error encrypting data for tenant {tenant_id}: {e}")
            raise

    def decrypt_tenant_data(self, tenant_id: str, encrypted_data: Dict[str, Any]) -> Dict[str, Any]:
        """Decrypt sensitive data for a tenant"""
        try:
            # Get tenant-specific encryption key
            encryption_key = self._get_tenant_encryption_key(tenant_id)

            # Decrypt sensitive fields
            decrypted_data = encrypted_data.copy()

            sensitive_fields = [
                'ssn', 'bank_account', 'pan_card', 'aadhar_number',
                'medical_history', 'financial_info', 'password',
                'emergency_contact', 'address'
            ]

            for field in sensitive_fields:
                if field in decrypted_data and decrypted_data[field]:
                    try:
                        decrypted_data[field] = self._decrypt_field(
                            decrypted_data[field], encryption_key
                        )
                    except Exception:
                        # If decryption fails, keep encrypted value
                        logger.warning(f"Failed to decrypt field {field} for tenant {tenant_id}")

            return decrypted_data

        except Exception as e:
            logger.error(f"Error decrypting data for tenant {tenant_id}: {e}")
            raise

    def _get_tenant_encryption_key(self, tenant_id: str) -> bytes:
        """Get or create tenant-specific encryption key"""
        cache_key = f"tenant_key:{tenant_id}"

        # Check cache first
        if cache_key in self._tenant_keys:
            cached_key, timestamp = self._tenant_keys[cache_key]
            if datetime.now().timestamp() - timestamp < self._key_cache_ttl:
                return cached_key

        # Generate tenant-specific key using envelope encryption
        # In production, this would use KMS to generate a data key
        tenant_key = self._derive_tenant_key(tenant_id)

        # Cache the key
        self._tenant_keys[cache_key] = (tenant_key, datetime.now().timestamp())

        return tenant_key

    def _derive_tenant_key(self, tenant_id: str) -> bytes:
        """Derive tenant-specific key from master key"""
        # Use PBKDF2 to derive tenant-specific key
        salt = tenant_id.encode()  # Use tenant_id as salt for consistency

        kdf = PBKDF2HMAC(
            algorithm=hashes.SHA256(),
            length=32,
            salt=salt,
            iterations=100000,  # High iteration count for security
        )

        key = base64.urlsafe_b64decode(self.master_key)
        tenant_key = kdf.derive(key)

        return tenant_key

    def _encrypt_field(self, value: str, key: bytes) -> str:
        """Encrypt a single field value"""
        try:
            fernet = Fernet(base64.urlsafe_b64encode(key))
            encrypted = fernet.encrypt(value.encode())
            return base64.urlsafe_b64encode(encrypted).decode()
        except Exception as e:
            logger.error(f"Error encrypting field: {e}")
            raise

    def _decrypt_field(self, encrypted_value: str, key: bytes) -> str:
        """Decrypt a single field value"""
        try:
            fernet = Fernet(base64.urlsafe_b64encode(key))
            encrypted = base64.urlsafe_b64decode(encrypted_value)
            decrypted = fernet.decrypt(encrypted)
            return decrypted.decode()
        except Exception as e:
            logger.error(f"Error decrypting field: {e}")
            raise

    def rotate_tenant_keys(self, tenant_id: str) -> bool:
        """Rotate encryption keys for a tenant"""
        try:
            # Clear cached key to force regeneration
            cache_key = f"tenant_key:{tenant_id}"
            self._tenant_keys.pop(cache_key, None)

            # In production, this would:
            # 1. Generate new data key from KMS
            # 2. Re-encrypt all tenant data with new key
            # 3. Update key references
            # 4. Archive old key

            logger.info(f"Rotated encryption keys for tenant {tenant_id}")
            return True

        except Exception as e:
            logger.error(f"Key rotation failed for tenant {tenant_id}: {e}")
            return False

    def encrypt_file(self, tenant_id: str, file_data: bytes, filename: str) -> Dict[str, Any]:
        """Encrypt file data for a tenant"""
        try:
            encryption_key = self._get_tenant_encryption_key(tenant_id)
            fernet = Fernet(base64.urlsafe_b64encode(encryption_key))

            encrypted_data = fernet.encrypt(file_data)

            return {
                'encrypted_data': base64.urlsafe_b64encode(encrypted_data).decode(),
                'encryption_key_id': f"tenant-{tenant_id}-file-key",
                'algorithm': 'Fernet',
                'filename': filename,
                'encrypted_at': datetime.utcnow().isoformat(),
            }

        except Exception as e:
            logger.error(f"Error encrypting file for tenant {tenant_id}: {e}")
            raise

    def decrypt_file(self, tenant_id: str, encrypted_file_data: Dict[str, Any]) -> bytes:
        """Decrypt file data for a tenant"""
        try:
            encryption_key = self._get_tenant_encryption_key(tenant_id)
            fernet = Fernet(base64.urlsafe_b64encode(encryption_key))

            encrypted_data = base64.urlsafe_b64decode(encrypted_file_data['encrypted_data'])
            decrypted_data = fernet.decrypt(encrypted_data)

            return decrypted_data

        except Exception as e:
            logger.error(f"Error decrypting file for tenant {tenant_id}: {e}")
            raise

    def hash_sensitive_data(self, data: str, salt: Optional[str] = None) -> str:
        """Create a hash of sensitive data for comparison (one-way)"""
        try:
            if not salt:
                salt = base64.urlsafe_b64encode(os.urandom(16)).decode()

            # Use PBKDF2 for password-like hashing
            kdf = PBKDF2HMAC(
                algorithm=hashes.SHA256(),
                length=32,
                salt=salt.encode(),
                iterations=100000,
            )

            hash_bytes = kdf.derive(data.encode())
            hash_str = base64.urlsafe_b64encode(hash_bytes).decode()

            return f"{salt}:{hash_str}"

        except Exception as e:
            logger.error(f"Error hashing sensitive data: {e}")
            raise

    def verify_sensitive_data(self, data: str, hashed_data: str) -> bool:
        """Verify sensitive data against its hash"""
        try:
            salt, hash_str = hashed_data.split(':', 1)

            # Re-hash the data with the same salt
            kdf = PBKDF2HMAC(
                algorithm=hashes.SHA256(),
                length=32,
                salt=salt.encode(),
                iterations=100000,
            )

            hash_bytes = kdf.derive(data.encode())
            computed_hash = base64.urlsafe_b64encode(hash_bytes).decode()

            return computed_hash == hash_str

        except Exception as e:
            logger.error(f"Error verifying sensitive data: {e}")
            return False

    def get_encryption_status(self, tenant_id: str) -> Dict[str, Any]:
        """Get encryption status for a tenant"""
        try:
            has_key = f"tenant_key:{tenant_id}" in self._tenant_keys
            last_rotation = None

            # In production, this would check key metadata
            return {
                'tenant_id': tenant_id,
                'encryption_enabled': True,
                'key_available': has_key,
                'algorithm': 'Fernet-with-PBKDF2',
                'last_key_rotation': last_rotation,
                'sensitive_fields_encrypted': [
                    'ssn', 'bank_account', 'pan_card', 'aadhar_number',
                    'medical_history', 'financial_info', 'emergency_contact'
                ],
            }

        except Exception as e:
            logger.error(f"Error getting encryption status for tenant {tenant_id}: {e}")
            return {'error': str(e)}


# Production KMS Integration (Placeholder for future implementation)
class KMSClient:
    """Placeholder for KMS integration"""

    def generate_data_key(self, key_id: str, key_spec: str = 'AES_256'):
        """Generate data key using KMS"""
        # TODO: Implement AWS KMS or similar integration
        # For now, return mock data
        return {
            'Plaintext': os.urandom(32),
            'CiphertextBlob': os.urandom(64),
        }

    def decrypt(self, ciphertext_blob: bytes):
        """Decrypt data key using KMS"""
        # TODO: Implement KMS decryption
        return {'Plaintext': os.urandom(32)}
