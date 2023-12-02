# modules/compute/main.tf

resource "aws_launch_template" "lab-lt" {
  name_prefix   = "Lab-Launch-Template"
  image_id      = var.ami_id
  instance_type = "t2.micro"
  vpc_security_group_ids = [var.asg_id] 
}

resource "aws_autoscaling_group" "lab-asg" {
  depends_on = [ var.tg_dependency ]

  desired_capacity = 4
  max_size         = 6
  min_size         = 2
  
  launch_template {
    id      = aws_launch_template.lab-lt.id
    version = "${aws_launch_template.lab-lt.latest_version}"
  }

  vpc_zone_identifier = var.subnet_ids
  target_group_arns = [var.tg_arn_asg]
  

  tag {
    key                 = "Name"
    value               = "Lab-ASG-instance"
    propagate_at_launch = true
  }
}
