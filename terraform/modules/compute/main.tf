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
  vpc_security_group_ids = [var.asg_id] 
}

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

/*

# CodeDeploy Application
resource "aws_codedeploy_application" "lab-codedeploy-app" {
  name     = "LabCodeDeployApp"
  compute_platform = "Server"

  deployment_config_name = "CodeDeployDefault.OneAtATime" # You can choose a different deployment configuration
}

resource "aws_codedeploy_deployment_group" "lab-codedeploy-deployment-group" {
  app_name     = aws_codedeploy_application.lab-codedeploy-app.name
  deployment_group_name = "LabCodeDeployDeploymentGroup"
  service_role_arn = "arn:aws:iam::656967617759:role/my-node-iam-role"  # Use your existing CodeDeploy service role ARN
  autoscaling_groups = [aws_autoscaling_group.lab-asg.name]

  # Specify your artifact details, including the location of appspec.yaml
  revision {
    revision_type    = "S3"
    s3_location {
      bucket = "your-s3-bucket-name"
      key    = "path/to/your/artifact.zip"
      bundle_type = "zip"  # Specify the bundle type if it's different
    }
  }
}

*/



