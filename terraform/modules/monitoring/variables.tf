variable "asg_id" {
  description = "IDs of ec2 instances launched by asg"
}

variable "asg_dependency" {
  description = "dependency for cloudwatch dashboard"
}

variable "alb_arn" {
  description = "ALB arn for the dashboard"
}