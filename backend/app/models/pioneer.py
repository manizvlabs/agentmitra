"""
Pioneer Feature Flag Models
Models for Pioneer feature flag database integration
"""

from sqlalchemy import Column, Integer, String, Boolean, Text, TIMESTAMP, func, CheckConstraint
from sqlalchemy.ext.declarative import declarative_base

Base = declarative_base()


class PioneerFlag(Base):
    """Pioneer Feature Flag model"""
    __tablename__ = "flags"
    __table_args__ = {'schema': 'public'}  # Pioneer uses public schema

    id = Column(Integer, primary_key=True, autoincrement=True)
    title = Column(String(100), unique=True, nullable=False, index=True)
    description = Column(Text, nullable=False, default="No description provided.")
    is_active = Column(Boolean, nullable=False, default=False)
    version = Column(Integer, default=1)
    rollout = Column(Integer, nullable=False, default=0)
    updated_at = Column(TIMESTAMP(timezone=True), nullable=False, default=func.now(), onupdate=func.now())
    created_at = Column(TIMESTAMP(timezone=True), nullable=False, default=func.now())

    # Check constraint for rollout percentage
    __table_args__ = (
        CheckConstraint('rollout >= 0 AND rollout <= 100', name='valid_rollout'),
        {'schema': 'public'}
    )

    def __repr__(self):
        return f"<PioneerFlag(id={self.id}, title='{self.title}', is_active={self.is_active}, rollout={self.rollout})>"


class PioneerKey(Base):
    """Pioneer API Keys model"""
    __tablename__ = "keys"
    __table_args__ = {'schema': 'public'}

    id = Column(Integer, primary_key=True, autoincrement=True)
    key_name = Column(String(100), unique=True, nullable=False)
    key_value = Column(String(255), nullable=False)
    is_valid = Column(Boolean, nullable=False, default=True)
    created_at = Column(TIMESTAMP(timezone=True), nullable=False, default=func.now())

    def __repr__(self):
        return f"<PioneerKey(id={self.id}, key_name='{self.key_name}', is_valid={self.is_valid})>"


class PioneerLog(Base):
    """Pioneer Audit Logs model"""
    __tablename__ = "logs"
    __table_args__ = {'schema': 'public'}

    id = Column(Integer, primary_key=True, autoincrement=True)
    action = Column(String(50), nullable=False)
    flag_id = Column(Integer, nullable=True)
    details = Column(Text)
    timestamp = Column(TIMESTAMP(timezone=True), nullable=False, default=func.now())

    def __repr__(self):
        return f"<PioneerLog(id={self.id}, action='{self.action}', flag_id={self.flag_id})>"
