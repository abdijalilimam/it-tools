variable "vpc_name" {
  description = "The name of the vpc"
  type        = string
}
variable "vpc_cidr" {
  description = "The range of the VPC"
  type        = string
}

variable "public_subnet_cidr" {
  description = "The range of the public subnet"
  type        = list(string)
}

variable "private_subnet_cidr" {
  description = "The range of the private subnet"
  type        = list(string)
}

variable "availability_zone" {
  description = "where resources live"
  type        = list(string)
}