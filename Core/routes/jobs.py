"""
Job management API routes
Handles image upload, job creation, and status queries
"""
from fastapi import APIRouter, UploadFile, File, Form, Depends, HTTPException, BackgroundTasks
from sqlalchemy.orm import Session
from typing import List
import os
import uuid
import logging
from datetime import datetime
import shutil

from database import get_db
from models import Job, JobResponse, JobListResponse, JobStatus, ErrorResponse
from services import get_fal_service

logger = logging.getLogger(__name__)

router = APIRouter()

# Upload directory
UPLOAD_DIR = "uploads"
os.makedirs(UPLOAD_DIR, exist_ok=True)


async def process_image_edit(
    job_id: str,
    image_path: str,
    prompt: str,
    db: Session
):
    """
    Background task to process image editing
    
    Args:
        job_id: Job identifier
        image_path: Path to uploaded image
        prompt: Edit prompt
        db: Database session
    """
    try:
        # Update job status to processing
        job = db.query(Job).filter(Job.id == job_id).first()
        if not job:
            logger.error(f"Job {job_id} not found")
            return
        
        job.status = JobStatus.PROCESSING.value
        job.updated_at = datetime.utcnow()
        db.commit()
        
        logger.info(f"Processing job {job_id}")
        
        # Get fal service and edit image
        fal_service = get_fal_service()
        result = await fal_service.edit_image(
            image_path=image_path,
            prompt=prompt
        )
        
        # Update job with result
        job.result_image_url = result["url"]
        job.fal_request_id = result.get("request_id")
        job.status = JobStatus.COMPLETED.value
        job.updated_at = datetime.utcnow()
        db.commit()
        
        logger.info(f"Job {job_id} completed successfully")
        
    except Exception as e:
        logger.error(f"Error processing job {job_id}: {str(e)}")
        
        # Update job with error
        job = db.query(Job).filter(Job.id == job_id).first()
        if job:
            job.status = JobStatus.FAILED.value
            job.error_message = str(e)
            job.updated_at = datetime.utcnow()
            db.commit()


@router.post("/jobs", response_model=JobResponse)
async def create_job(
    background_tasks: BackgroundTasks,
    image: UploadFile = File(...),
    prompt: str = Form(...),
    db: Session = Depends(get_db)
):
    """
    Create a new image editing job
    
    Args:
        image: Uploaded image file
        prompt: Text description of desired edits
        db: Database session
        
    Returns:
        Created job details
    """
    try:
        # Validate file type
        allowed_types = ["image/jpeg", "image/jpg", "image/png", "image/webp"]
        if image.content_type not in allowed_types:
            raise HTTPException(
                status_code=400,
                detail=f"Invalid file type. Allowed types: {', '.join(allowed_types)}"
            )
        
        # Generate unique job ID
        job_id = str(uuid.uuid4())
        
        # Save uploaded file
        file_extension = os.path.splitext(image.filename)[1]
        image_filename = f"{job_id}{file_extension}"
        image_path = os.path.join(UPLOAD_DIR, image_filename)
        
        with open(image_path, "wb") as buffer:
            shutil.copyfileobj(image.file, buffer)
        
        logger.info(f"Image saved: {image_path}")
        
        # Create job in database
        new_job = Job(
            id=job_id,
            prompt=prompt,
            original_image_path=image_path,
            status=JobStatus.PENDING.value,
            created_at=datetime.utcnow(),
            updated_at=datetime.utcnow()
        )
        
        db.add(new_job)
        db.commit()
        db.refresh(new_job)
        
        logger.info(f"Job created: {job_id}")
        
        # Start background processing
        background_tasks.add_task(
            process_image_edit,
            job_id=job_id,
            image_path=image_path,
            prompt=prompt,
            db=db
        )
        
        return JobResponse.model_validate(new_job)
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error creating job: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/jobs/{job_id}", response_model=JobResponse)
async def get_job(
    job_id: str,
    db: Session = Depends(get_db)
):
    """
    Get job details by ID
    
    Args:
        job_id: Job identifier
        db: Database session
        
    Returns:
        Job details
    """
    try:
        job = db.query(Job).filter(Job.id == job_id).first()
        
        if not job:
            raise HTTPException(status_code=404, detail="Job not found")
        
        return JobResponse.model_validate(job)
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error getting job {job_id}: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/jobs", response_model=JobListResponse)
async def list_jobs(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db)
):
    """
    List all jobs
    
    Args:
        skip: Number of records to skip
        limit: Maximum number of records to return
        db: Database session
        
    Returns:
        List of jobs
    """
    try:
        # Get total count
        total = db.query(Job).count()
        
        # Get jobs with pagination
        jobs = db.query(Job)\
            .order_by(Job.created_at.desc())\
            .offset(skip)\
            .limit(limit)\
            .all()
        
        job_responses = [JobResponse.model_validate(job) for job in jobs]
        
        return JobListResponse(
            jobs=job_responses,
            total=total
        )
        
    except Exception as e:
        logger.error(f"Error listing jobs: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))


@router.delete("/jobs/{job_id}")
async def delete_job(
    job_id: str,
    db: Session = Depends(get_db)
):
    """
    Delete a job
    
    Args:
        job_id: Job identifier
        db: Database session
        
    Returns:
        Success message
    """
    try:
        job = db.query(Job).filter(Job.id == job_id).first()
        
        if not job:
            raise HTTPException(status_code=404, detail="Job not found")
        
        # Delete uploaded image file
        if os.path.exists(job.original_image_path):
            os.remove(job.original_image_path)
        
        # Delete job from database
        db.delete(job)
        db.commit()
        
        logger.info(f"Job {job_id} deleted")
        
        return {"message": "Job deleted successfully", "job_id": job_id}
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error deleting job {job_id}: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))
