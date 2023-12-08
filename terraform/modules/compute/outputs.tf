# modules/compute/outputs.tf


output "asg_id" {
  value = aws_autoscaling_group.lab-asg.id
}

output "asg_dependency" {
  value = aws_autoscaling_group.lab-asg
}
