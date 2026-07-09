variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-2"
}

variable "project_name" {
  description = "Name prefix for all resources"
  type        = string
  default     = "it-tools"
}
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidr" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "availability_zone" {
  description = "Availability zones"
  type        = list(string)
  default     = ["us-east-2a", "us-east-2b"]
}

variable "container_image" {
  description = "ECR image URI for the container"
  type        = string
}

variable "domain_name" {
  description = "Domain name for ACM certificate"
  type        = string
  default     = "abdijalil.com"
}

variable "cpu" {
  description = "CPU units for ECS task"
  type        = string
  default     = "256"
}

variable "memory" {
  description = "Memory for ECS task"
  type        = string
  default     = "512"
}