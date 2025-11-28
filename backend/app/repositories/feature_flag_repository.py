"""
Feature Flag Repository
Handles database operations for feature flags
"""

from typing import List, Dict, Any, Optional
from sqlalchemy.orm import Session
from sqlalchemy import text

from app.core.config.settings import settings
from app.core.logging_config import get_logger

logger = get_logger(__name__)


class FeatureFlagRepository:
    """Repository for feature flag database operations"""

    def __init__(self, db: Session):
        self.db = db

    async def get_user_flags(self, user_id: str, tenant_id: Optional[str] = None) -> List[Dict[str, Any]]:
        """Get feature flags for a specific user, considering overrides"""
        try:
            query = f"""
                SELECT
                    ff.flag_name,
                    COALESCE(ufo.override_value, tfo.override_value, ff.default_value, false) as value,
                    ff.default_value,
                    ff.flag_description,
                    ff.flag_type
                FROM {settings.db_schema}.feature_flags ff
                LEFT JOIN {settings.db_schema}.feature_flag_overrides ufo
                    ON ff.flag_id = ufo.flag_id AND ufo.user_id = :user_id
                LEFT JOIN {settings.db_schema}.feature_flag_overrides tfo
                    ON ff.flag_id = tfo.flag_id AND tfo.tenant_id = :tenant_id AND tfo.user_id IS NULL
                WHERE ff.is_enabled = true
                ORDER BY ff.flag_name
            """

            result = await self.db.execute(text(query), {"user_id": user_id, "tenant_id": tenant_id})
            return [dict(row) for row in result.fetchall()]

        except Exception as e:
            logger.error(f"Error getting user flags for {user_id}: {e}")
            return []

    async def get_tenant_flags(self, tenant_id: str) -> List[Dict[str, Any]]:
        """Get feature flags for a specific tenant"""
        try:
            query = f"""
                SELECT
                    ff.flag_name,
                    COALESCE(tfo.override_value, ff.default_value, false) as value,
                    ff.default_value,
                    ff.flag_description,
                    ff.flag_type
                FROM {settings.db_schema}.feature_flags ff
                LEFT JOIN {settings.db_schema}.feature_flag_overrides tfo
                    ON ff.flag_id = tfo.flag_id AND tfo.tenant_id = :tenant_id
                WHERE ff.is_enabled = true
                ORDER BY ff.flag_name
            """

            result = await self.db.execute(text(query), {"tenant_id": tenant_id})
            return [dict(row) for row in result.fetchall()]

        except Exception as e:
            logger.error(f"Error getting tenant flags for {tenant_id}: {e}")
            return []

    async def get_all_flags(self) -> List[Dict[str, Any]]:
        """Get all feature flags with their current values"""
        try:
            query = f"""
                SELECT
                    ff.flag_id,
                    ff.flag_name,
                    ff.flag_description,
                    ff.flag_type,
                    ff.default_value,
                    ff.is_enabled,
                    ff.tenant_id,
                    ff.created_at,
                    ff.updated_at
                FROM {settings.db_schema}.feature_flags ff
                ORDER BY ff.flag_name
            """

            result = await self.db.execute(text(query))
            return [dict(row) for row in result.fetchall()]

        except Exception as e:
            logger.error(f"Error getting all flags: {e}")
            return []

    async def update_flag_value(self, flag_name: str, value: bool,
                              user_id: Optional[str] = None,
                              tenant_id: Optional[str] = None) -> bool:
        """Update or create a feature flag override"""
        try:
            # First, get the flag ID
            flag_query = f"""
                SELECT flag_id FROM {settings.db_schema}.feature_flags
                WHERE flag_name = :flag_name
            """
            flag_result = await self.db.execute(text(flag_query), {"flag_name": flag_name})
            flag_row = flag_result.first()

            if not flag_row:
                logger.error(f"Feature flag {flag_name} not found")
                return False

            flag_id = flag_row[0]

            # Check if override exists
            override_query = f"""
                SELECT override_id FROM {settings.db_schema}.feature_flag_overrides
                WHERE flag_id = :flag_id
                  AND user_id IS NOT DISTINCT FROM :user_id
                  AND tenant_id IS NOT DISTINCT FROM :tenant_id
            """
            override_result = await self.db.execute(text(override_query),
                                                   {"flag_id": flag_id, "user_id": user_id, "tenant_id": tenant_id})
            override_row = override_result.first()

            if override_row:
                # Update existing override
                update_query = f"""
                    UPDATE {settings.db_schema}.feature_flag_overrides
                    SET override_value = :value, updated_at = NOW()
                    WHERE override_id = :override_id
                """
                await self.db.execute(text(update_query), {"value": value, "override_id": override_row[0]})
            else:
                # Create new override
                insert_query = f"""
                    INSERT INTO {settings.db_schema}.feature_flag_overrides
                    (flag_id, user_id, tenant_id, override_value, created_at)
                    VALUES (:flag_id, :user_id, :tenant_id, :value, NOW())
                """
                await self.db.execute(text(insert_query),
                                    {"flag_id": flag_id, "user_id": user_id, "tenant_id": tenant_id, "value": value})

            await self.db.commit()
            return True

        except Exception as e:
            logger.error(f"Error updating flag {flag_name}: {e}")
            await self.db.rollback()
            return False

    async def delete_flag_override(self, flag_name: str,
                                 user_id: Optional[str] = None,
                                 tenant_id: Optional[str] = None) -> bool:
        """Delete a feature flag override"""
        try:
            query = f"""
                DELETE FROM {settings.db_schema}.feature_flag_overrides
                WHERE flag_id IN (
                    SELECT flag_id FROM {settings.db_schema}.feature_flags
                    WHERE flag_name = :flag_name
                )
                AND user_id IS NOT DISTINCT FROM :user_id
                AND tenant_id IS NOT DISTINCT FROM :tenant_id
            """

            result = await self.db.execute(text(query), {"flag_name": flag_name, "user_id": user_id, "tenant_id": tenant_id})
            await self.db.commit()

            return result.rowcount > 0

        except Exception as e:
            logger.error(f"Error deleting flag override for {flag_name}: {e}")
            await self.db.rollback()
            return False

    async def create_flag(self, flag_name: str, description: str = "",
                         flag_type: str = "boolean", default_value: Any = False,
                         tenant_id: Optional[str] = None) -> bool:
        """Create a new feature flag"""
        try:
            query = f"""
                INSERT INTO {settings.db_schema}.feature_flags
                (flag_name, flag_description, flag_type, default_value, is_enabled, tenant_id)
                VALUES (:flag_name, :description, :flag_type, :default_value, true, :tenant_id)
                ON CONFLICT (flag_name) DO NOTHING
            """

            result = await self.db.execute(text(query), {
                "flag_name": flag_name,
                "description": description,
                "flag_type": flag_type,
                "default_value": default_value,
                "tenant_id": tenant_id
            })

            await self.db.commit()
            return result.rowcount > 0

        except Exception as e:
            logger.error(f"Error creating flag {flag_name}: {e}")
            await self.db.rollback()
            return False
