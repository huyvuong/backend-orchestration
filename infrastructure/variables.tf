variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-west-2"
}

variable "environment" {
  description = "Environment name (e.g. dev, prod)"
  type        = string
  default     = "prod"
}

variable "private_subnets" {
  description = "List of private subnets for AWS Batch"
  type        = list(string)
  default     = ["subnet-12345", "subnet-67890"]
}

variable "security_group_id" {
  description = "Security group for AWS Batch instances"
  type        = string
  default     = "sg-12345678"
}
