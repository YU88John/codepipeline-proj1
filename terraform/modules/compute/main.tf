# modules/compute/main.tf

# IAM role for ec2 instances
resource "aws_iam_role" "lab_code_deploy_role_ec2" {
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

# for reading artifacts from s3 
resource "aws_iam_role_policy_attachment" "lab_code_deploy_policy_attachment_1" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforAWSCodeDeploy"
  role       = aws_iam_role.lab_code_deploy_role_ec2.name
}

# for cloudwatch dashboard
resource "aws_iam_role_policy_attachment" "lab_code_deploy_policy_attachment_2" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.lab_code_deploy_role_ec2.name
}

resource "aws_iam_instance_profile" "lab_code_deploy_instance_profile" {
  name = "lab-code-deploy-instance-profile"
  role = aws_iam_role.lab_code_deploy_role_ec2.name
}

# IAM role for CodeDeploy application
resource "aws_iam_role" "lab_codedeploy_role" {
  name = "lab-codedeploy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "codedeploy.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lab_codedeploy_policy_attachment_1" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
  role       = aws_iam_role.lab_codedeploy_role.name
}

# Launch template for auto scaling group
resource "aws_launch_template" "lab-lt" {
  depends_on = [ aws_iam_role.lab_code_deploy_role_ec2 ]
  name_prefix   = "Lab-Launch-Template"
  image_id      = var.ami_id
  instance_type = "t2.micro"
   iam_instance_profile {
    name = aws_iam_instance_profile.lab_code_deploy_instance_profile.name
  }
  vpc_security_group_ids = [var.asg_id] 
}

# Create autoscaling group
resource "aws_autoscaling_group" "lab-asg" {
  depends_on = [var.tg_dependency]

  desired_capacity = 4
  max_size         = 6
  min_size         = 2

  launch_template {
    id      = aws_launch_template.lab-lt.id
    version = "${aws_launch_template.lab-lt.latest_version}"
  }

  vpc_zone_identifier = var.subnet_ids
  target_group_arns   = [var.tg_arn_asg]

  tag {
    key                 = "Name"
    value               = "Lab-ASG-instance"
    propagate_at_launch = true
  }
}


# CodeDeploy Application
resource "aws_codedeploy_app" "lab-codedeploy-app" {
  name     = "LabCodeDeployApp"
  compute_platform = "Server"
}

resource "aws_codedeploy_deployment_group" "lab-codedeploy-deployment-group" {
  app_name     = aws_codedeploy_app.lab-codedeploy-app.name
  deployment_config_name = "CodeDeployDefault.HalfAtATime" # Only half of the deployment group will be deployed at the same time
  deployment_group_name = "LabCodeDeployDeploymentGroup"
  service_role_arn = aws_iam_role.lab_codedeploy_role.arn
  autoscaling_groups = [aws_autoscaling_group.lab-asg.name]

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

   # Specify the load balancer and target group information - for draining during deployment
  load_balancer_info {
    elb_info {
      name = var.alb_name
    }
    target_group_info {
      name = var.tg_name
    }
  }
  
}




