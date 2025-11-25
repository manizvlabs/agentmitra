"""
User-Role Association Model
"""
from sqlalchemy import Column, DateTime, func, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from ..base import Base


class UserRole(Base):
    """Association between users and roles"""
    __tablename__ = "user_roles"
    __table_args__ = {'schema': 'lic_schema'}

    user_role_id = Column(UUID(as_uuid=True), primary_key=True, default=func.gen_random_uuid())
    user_id = Column(UUID(as_uuid=True), ForeignKey('lic_schema.users.user_id'), nullable=False)
    role_id = Column(UUID(as_uuid=True), ForeignKey('lic_schema.roles.role_id'), nullable=False)
    assigned_by = Column(UUID(as_uuid=True), ForeignKey('lic_schema.users.user_id'))
    assigned_at = Column(DateTime, default=func.now())

    def __repr__(self):
        return f"<UserRole(user_id={self.user_id}, role_id={self.role_id})>"
