#!/usr/bin/env bash
# debug_pipeline.sh
# Fetches and tails logs for a given Nextflow run ID from AWS Batch or SLURM.
# Usage: ./debug_pipeline.sh <RUN_ID> <ENVIRONMENT: aws|slurm>

set -euo pipefail

RUN_ID=${1:-""}
ENV=${2:-"aws"}

if [ -z "$RUN_ID" ]; then
  echo "Error: Must provide a RUN_ID."
  echo "Usage: $0 <RUN_ID> <aws|slurm>"
  exit 1
fi

echo "Gathering logs for RUN_ID: $RUN_ID in environment: $ENV..."

if [ "$ENV" == "aws" ]; then
  # In a real environment, this would query AWS Batch jobs or CloudWatch logs
  # Example: aws logs get-log-events --log-group-name /aws/batch/job --log-stream-name ...
  echo "[AWS Batch] Fetching CloudWatch Logs for Nextflow Head Job associated with $RUN_ID..."
  echo "Simulated log: ERROR - Process 'dragen_variant_call' failed with exit status 1"
  echo "Hint: Check S3 bucket for the execution working directory (.command.log, .command.err)"
elif [ "$ENV" == "slurm" ]; then
  # Fetch slurm logs
  echo "[SLURM] Searching for slurm out files related to $RUN_ID..."
  # Example: sacct -j <jobid> --format=JobID,JobName,State,ExitCode
  echo "Simulated log: OOM Killer terminated process 'nf-core/sarek'"
else
  echo "Unknown environment: $ENV. Please use 'aws' or 'slurm'."
  exit 1
fi
