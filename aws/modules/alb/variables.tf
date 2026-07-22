variable "alb_name" {
  description = "The name of the load balancer"
  type        = string
}

variable "vpc_id" {
  description = "The id of the vpc"
  type        = string
}

variable "public_subnet_ids" {
  description = "The public subnet ids"
  type        = list(string)
}

variable "certificate_arn" {
  description = "ARN of the ACM certificate"
  type        = string
}