terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# 1. S3 Landing Zone for Sequencing Data
resource "aws_s3_bucket" "sequencing_data" {
  bucket = "illumina-sequencing-landing-zone-${var.environment}"
}

# 2. SQS Queue for Event Notifications
resource "aws_sqs_queue" "s3_events" {
  name                       = "s3-upload-events-${var.environment}"
  visibility_timeout_seconds = 60
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.s3_events_dlq.arn
    maxReceiveCount     = 3
  })
}

resource "aws_sqs_queue" "s3_events_dlq" {
  name = "s3-upload-events-dlq-${var.environment}"
}

# S3 Event Notification to SQS
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.sequencing_data.id

  queue {
    queue_arn     = aws_sqs_queue.s3_events.arn
    events        = ["s3:ObjectCreated:*"]
    filter_suffix = ".fastq.gz"
  }
}

# 3. AWS Batch Compute Environment (Targeting f1 instances for DRAGEN or standard for nf-core)
resource "aws_batch_compute_environment" "nextflow_env" {
  compute_environment_name = "nextflow-compute-${var.environment}"
  type                     = "MANAGED"
  state                    = "ENABLED"

  compute_resources {
    type           = "EC2"
    max_vcpus      = 256
    min_vcpus      = 0
    instance_type  = ["c5", "m5", "r5", "f1.2xlarge"] # Include f1 for DRAGEN
    subnets        = var.private_subnets
    security_group_ids = [var.security_group_id]
    instance_role  = aws_iam_instance_profile.ecs_instance_role.arn
  }
  service_role = aws_iam_role.aws_batch_service_role.arn
}

resource "aws_batch_job_queue" "nextflow_queue" {
  name                 = "nextflow-queue-${var.environment}"
  state                = "ENABLED"
  priority             = 1
  compute_environments = [aws_batch_compute_environment.nextflow_env.arn]
}

# Standard IAM stub for completeness
resource "aws_iam_role" "aws_batch_service_role" {
  name = "aws_batch_service_role_${var.environment}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "batch.amazonaws.com" }
    }]
  })
}

resource "aws_iam_instance_profile" "ecs_instance_role" {
  name = "ecs_instance_role_${var.environment}"
  role = aws_iam_role.ecs_role.name
}

resource "aws_iam_role" "ecs_role" {
  name = "ecs_role_${var.environment}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}
