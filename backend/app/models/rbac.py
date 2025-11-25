"""
RBAC (Role-Based Access Control) Models
"""
from sqlalchemy import Column, String, Boolean, Integer, DateTime, TEXT, func, ForeignKey, Table
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.orm import relationship
from .base import Base


class Role(Base):
    """User roles in the RBAC system"""
    __tablename__ = "roles"
    __table_args__ = {'schema': 'lic_schema'}

    role_id = Column(UUID(as_uuid=True), primary_key=True, default=func.gen_random_uuid())
    role_name = Column(String(100), unique=True, nullable=False)
    role_description = Column(TEXT)
    is_system_role = Column(Boolean, default=False)
    hierarchy_level = Column(Integer, default=0)  # For role inheritance
    created_at = Column(DateTime, default=func.now())
    updated_at = Column(DateTime, default=func.now())

    # Relationships will be added after basic model setup

    # Relationships - causing TextClause error, will be added later

    def __repr__(self):
        return f"<Role(role_name={self.role_name})>"


class Permission(Base):
    """Permissions in the RBAC system"""
    __tablename__ = "permissions"
    __table_args__ = {'schema': 'lic_schema'}

    permission_id = Column(UUID(as_uuid=True), primary_key=True, default=func.gen_random_uuid())
    permission_name = Column(String(100), unique=True, nullable=False)
    permission_description = Column(TEXT)
    resource = Column(String(100), nullable=False)  # e.g., 'users', 'policies', 'agents'
    action = Column(String(50), nullable=False)     # e.g., 'create', 'read', 'update', 'delete'
    is_system_permission = Column(Boolean, default=False)
    created_at = Column(DateTime, default=func.now())
    updated_at = Column(DateTime, default=func.now())

    # Relationships - causing TextClause error, will be added later

    def __repr__(self):
        return f"<Permission(permission_name={self.permission_name})>"




class RolePermission(Base):
    """Association between roles and permissions"""
    __tablename__ = "role_permissions"
    __table_args__ = {'schema': 'lic_schema'}

    role_permission_id = Column(UUID(as_uuid=True), primary_key=True, default=func.gen_random_uuid())
    role_id = Column(UUID(as_uuid=True), ForeignKey('lic_schema.roles.role_id'), nullable=False)
    permission_id = Column(UUID(as_uuid=True), ForeignKey('lic_schema.permissions.permission_id'), nullable=False)
    assigned_by = Column(UUID(as_uuid=True), ForeignKey('lic_schema.users.user_id'))
    assigned_at = Column(DateTime, default=func.now())

    # Relationships - causing TextClause error, will be added later

    def __repr__(self):
        return f"<RolePermission(role_id={self.role_id}, permission_id={self.permission_id})>"


class UserRole(Base):
    """Association between users and roles"""
    __tablename__ = "user_roles"
    __table_args__ = {'schema': 'lic_schema'}

    user_role_id = Column(UUID(as_uuid=True), primary_key=True, default=func.gen_random_uuid())
    user_id = Column(UUID(as_uuid=True), ForeignKey('lic_schema.users.user_id'), nullable=False)
    role_id = Column(UUID(as_uuid=True), ForeignKey('lic_schema.roles.role_id'), nullable=False)
    assigned_by = Column(UUID(as_uuid=True), ForeignKey('lic_schema.users.user_id'))
    assigned_at = Column(DateTime, default=func.now())

    # Relationships - causing TextClause error, will be added later

    def __repr__(self):
        return f"<UserRole(user_id={self.user_id}, role_id={self.role_id})>"
