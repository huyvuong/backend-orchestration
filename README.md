# Automated High-Throughput Clinical Genomic Pipeline Orchestrator

This repository is a prototype project of a modern, event-driven architecture designed to orchestrate high-throughput genomics pipelines (like DRAGEN or nf-core/sarek). 

It specifically demonstrates deep expertise in:
- **Backend Systems**: Asynchronous task queuing (Celery/Redis), structured JSON logging, and robust REST APIs (FastAPI).
- **Infrastructure as Code**: Managing AWS infrastructure (Batch, S3, SQS, RDS) using Terraform.
- **Workflow Orchestration**: Targeting both traditional on-prem HPC clusters (SLURM) and cloud environments (AWS Batch) with Nextflow.
- **Production Support & CI/CD**: CloudWatch Alarms for Dead Letter Queues, strict linting (`ruff`, `shellcheck`), and automated testing.

## Architecture Overview

1.  **Event Source**: Sequencing data (BCL/FASTQ) is uploaded to an S3 bucket.
2.  **Queue**: S3 emits an Event Notification to an SQS queue.
3.  **Backend API**: A Python FastAPI service consumes the event and registers the sample metadata in PostgreSQL.
4.  **Task Queue**: The API asynchronously pushes a Nextflow dispatch task to a Celery worker (backed by Redis).
5.  **Scheduler**: The Celery worker templates the Nextflow parameters and dispatches the job to AWS Batch (Cloud) or SLURM (HPC).

## Directory Structure

- `backend/`: FastAPI application, Celery workers, and tests.
- `infrastructure/`: Terraform definitions for AWS resources.
- `nextflow/`: Profiles for AWS Batch and SLURM.
- `scripts/`: Linux bash scripts for debugging distributed systems and load testing.
- `.github/workflows/`: CI/CD automation.

## Quick Start (Local Development)

You can spin up the backend API, Redis, and PostgreSQL locally using Docker Compose:

```bash
docker compose up --build
```

Load Test the Celery Queue:
```bash
make test-load
```
