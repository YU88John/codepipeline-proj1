# modules/compute/main.tf

resource "aws_iam_role" "lab_code_deploy_role" {
  name = "lab-code-deploy"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lab_code_deploy_policy_attachment_1" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforAWSCodeDeploy"
  role       = aws_iam_role.lab_code_deploy_role.name
}

resource "aws_iam_role_policy_attachment" "lab_code_deploy_policy_attachment_2" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
  role       = aws_iam_role.lab_code_deploy_role.name
}

resource "aws_iam_instance_profile" "lab_code_deploy_instance_profile" {
  name = "lab-code-deploy-instance-profile"
  role = aws_iam_role.lab_code_deploy_role.name
}

resource "aws_launch_template" "lab-lt" {
  depends_on = [ aws_iam_role.lab_code_deploy_role ]
  name_prefix   = "Lab-Launch-Template"
  image_id      = var.ami_id
  instance_type = "t2.micro"
   iam_instance_profile {
    name = aws_iam_instance_profile.lab_code_deploy_instance_profile.name
  }
  user_data = filebase64("./modules/compute/code-deploy-agent.sh")
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
