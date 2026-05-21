from fastapi import FastAPI, Request, HTTPException, BackgroundTasks
from pydantic import BaseModel
from typing import Dict, Any, List
from .logger import log
import os

# Simulated Celery import to avoid running real broker in dev unless intended
try:
    from worker.tasks import dispatch_nextflow_pipeline
except ImportError:
    dispatch_nextflow_pipeline = None

app = FastAPI(title="Illumina Pipeline Orchestrator", version="1.0.0")

class S3Object(BaseModel):
    key: str

class S3Bucket(BaseModel):
    name: str

class S3Entity(BaseModel):
    bucket: S3Bucket
    object: S3Object

class S3Record(BaseModel):
    eventName: str
    s3: S3Entity

class S3Event(BaseModel):
    Records: List[S3Record]

@app.post("/webhook/s3", status_code=202)
async def handle_s3_upload(event: S3Event):
    """
    Webhook to receive S3 Event Notifications when new sequencing data lands.
    Extracts the sample ID and dispatches an async task to Celery to trigger Nextflow.
    """
    for record in event.Records:
        if "ObjectCreated" in record.eventName:
            bucket = record.s3.bucket.name
            key = record.s3.object.key
            
            # Example Key: runs/230521_A01234/SAMPLE_0001_R1.fastq.gz
            try:
                run_id = key.split('/')[1]
                filename = key.split('/')[-1]
                sample_id = filename.split('_')[0]
            except IndexError:
                log.error("Failed to parse S3 key format", extra={"s3_key": key})
                continue
                
            log.info("Received new sequencing data event", extra={
                "sample_id": sample_id,
                "run_id": run_id,
                "bucket": bucket
            })
            
            # Dispatch to Celery Queue
            if dispatch_nextflow_pipeline:
                dispatch_nextflow_pipeline.delay(sample_id, run_id, bucket, key)
            else:
                log.warning("Celery worker not found. Processing skipped.")

    return {"status": "accepted", "message": "Jobs queued successfully"}

@app.get("/health")
def health_check():
    """Endpoint for Load Balancer/Kubernetes health checks."""
    return {"status": "healthy"}
