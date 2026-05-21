import os
import time
from celery import Celery
from app.logger import log

REDIS_URL = os.getenv("REDIS_URL", "redis://localhost:6379/0")

celery_app = Celery(
    "orchestrator_worker",
    broker=REDIS_URL,
    backend=REDIS_URL
)

celery_app.conf.update(
    task_serializer="json",
    accept_content=["json"],
    result_serializer="json",
    timezone="UTC",
    enable_utc=True,
    # Rate limit submissions to the HPC scheduler to avoid overloading the head node
    task_default_rate_limit="10/m" 
)

@celery_app.task(bind=True, max_retries=3)
def dispatch_nextflow_pipeline(self, sample_id: str, run_id: str, bucket: str, s3_key: str):
    """
    Asynchronous task to template parameters and submit the Nextflow job.
    Includes automatic retries for transient scheduler/network failures.
    """
    log.info("Starting Nextflow dispatch process", extra={
        "sample_id": sample_id,
        "run_id": run_id
    })
    
    try:
        # Mock database registration and parameter templating
        time.sleep(1) 
        
        # In production, this uses subprocess to run `nextflow run nf-core/sarek ...`
        # or uses the Seqera Platform / AWS Batch API.
        mock_batch_job_id = f"job-{sample_id}-12345"
        
        log.info("Successfully dispatched Nextflow pipeline to scheduler", extra={
            "sample_id": sample_id,
            "run_id": run_id,
            "batch_job_id": mock_batch_job_id
        })
        
        return {"status": "success", "job_id": mock_batch_job_id}
        
    except Exception as exc:
        log.error("Failed to dispatch Nextflow pipeline, retrying...", exc_info=True, extra={
            "sample_id": sample_id,
            "run_id": run_id
        })
        # Exponential backoff for retries
        raise self.retry(exc=exc, countdown=2 ** self.request.retries)
