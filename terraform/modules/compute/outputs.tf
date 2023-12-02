# modules/compute/outputs.tf

output "asg_id" {
  value = aws_autoscaling_group.lab-asg.id
}
