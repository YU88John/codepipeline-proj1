# modules/database/variables.tf

variable "subnet_ids" {
  description = "List of subnet IDs for RDS instance"
}

variable "vpc_id" {
  description = "VPC ID"
}

variable "az-a" {
  description = "Availability Zone for RDS instance"
}

variable "sg_asg_id" {
  description = "ID of the security group for ALB"
}