# modules/compute/variables.tf

variable "ami_id" {
  description = "AMI ID for instances"
}

variable "subnet_ids" {
  description = "List of subnet IDs for instances"
}

variable "asg_id" {
  description = "Security group name for auto scaling group"
}

variable "tg_arn_asg" {
  description = "Target group arn for asg to be registered"
}

variable "tg_dependency" {
  description = "For explicit dependency of target group"
}

variable "tg_name" {
  description = "Name of target group for code deploy configuration"
}