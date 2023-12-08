# modules/networking/outputs.tf

output "vpc_id" {
  value = aws_vpc.lab-vpc.id
}

output "subnet_ids" {
  value = aws_subnet.lab-private-subnets[*].id
}

output "alb_security_group_id" {
  value = aws_security_group.lab-sg-alb.id
}

output "asg_security_group_id" {
  value = aws_security_group.lab-asg-sg.id
}

output "tg_arn" {
  value = aws_lb_target_group.lab-alb-tg.arn
}

output "tg_creation" {
  value = aws_lb_target_group.lab-alb-tg
}

output "tg_name4cd" {
  value = aws_lb_target_group.lab-alb-tg.name
}

output "rds_subnet_ids" {
  value = aws_subnet.lab-private-subnets-rds[*].id
}

output "alb_name" {
  value = aws_lb.lab-alb.name
}

output "alb_arn" {
  value = aws_lb.lab-alb.arn
}