# AWS Region
variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

# VPC ID (provided by instructor)
variable "vpc_id" {
  description = "VPC ID to use for the EC2 instance"
  type        = string
  default     = "vpc-044604d0bfb707142"
}

# Instance Type
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
  
  validation {
    condition = contains([
      "t3.small", "t3.medium", "t3.large",
      "t2.small", "t2.medium", "t2.large"
    ], var.instance_type)
    error_message = "Instance type must be a valid t2 or t3 instance type."
  }
}

# Environment
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "development"
}

# Project Name
variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "final-project-jb"
}
