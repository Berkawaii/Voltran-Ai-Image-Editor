"""
Database models for job management
"""
from sqlalchemy import Column, String, DateTime, Text, Integer
from datetime import datetime
from database import Base
from pydantic import BaseModel
from typing import Optional
from enum import Enum


class JobStatus(str, Enum):
    """Job status enumeration"""
    PENDING = "pending"
    PROCESSING = "processing"
    COMPLETED = "completed"
    FAILED = "failed"


# SQLAlchemy Model
class Job(Base):
    """
    Job database model
    """
    __tablename__ = "jobs"

    id = Column(String, primary_key=True, index=True)
    prompt = Column(Text, nullable=False)
    original_image_path = Column(String, nullable=False)
    result_image_url = Column(String, nullable=True)
    status = Column(String, default=JobStatus.PENDING.value)
    error_message = Column(Text, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    fal_request_id = Column(String, nullable=True)


# Pydantic Models (for API request/response)
class JobCreate(BaseModel):
    """Schema for creating a new job"""
    prompt: str


class JobResponse(BaseModel):
    """Schema for job response"""
    id: str
    prompt: str
    original_image_path: str
    result_image_url: Optional[str] = None
    status: str
    error_message: Optional[str] = None
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class JobListResponse(BaseModel):
    """Schema for listing jobs"""
    jobs: list[JobResponse]
    total: int


class ErrorResponse(BaseModel):
    """Schema for error responses"""
    error: str
    detail: Optional[str] = None
