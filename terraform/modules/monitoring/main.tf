resource "aws_cloudwatch_dashboard" "lab-dashboard" {
  depends_on     = [var.asg_dependency, var.alb_dependency, var.rds_dependency]
  dashboard_name = "Lab-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type       = "text"
        x          = 0
        y          = 0
        width      = 12
        height     = 3
        properties = {
          markdown = "My Lab Dashboard for EC2, ALB, and RDS"
        }
      },
      {
        type       = "metric"
        x          = 0
        y          = 3  
        width      = 12
        height     = 6
        properties = {
          metrics = [
            ["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", "${var.asg_id}"],
            ["AWS/EC2", "MemoryUtilization", "AutoScalingGroupName", "${var.asg_id}"],
            ["AWS/EC2", "DiskReadBytes", "AutoScalingGroupName", "${var.asg_id}"],
            ["AWS/EC2", "DiskWriteBytes", "AutoScalingGroupName", "${var.asg_id}"],
          ]
          period = 300
          stat   = "Average"
          region = "us-east-1"
          title  = "Auto Scaling Group - Resource Utilization"
        }
      },
      {
        type       = "metric"
        x          = 12
        y          = 3
        width      = 12
        height     = 6
        properties = {
          metrics = [
            ["AWS/EC2", "NetworkIn", "AutoScalingGroupName", "${var.asg_id}"],
            ["AWS/EC2", "NetworkOut", "AutoScalingGroupName", "${var.asg_id}"],
          ]
          period = 300
          stat   = "Average"
          region = "us-east-1"
          title  = "Auto Scaling Group - Network Traffic"
        }
      },
      {
        type       = "metric"
        x          = 0
        y          = 15  
        width      = 12
        height     = 6
        properties = {
          metrics = [
            ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", "${var.rds_instance_identifier}"],
            ["AWS/RDS", "FreeableMemory", "DBInstanceIdentifier", "${var.rds_instance_identifier}"],
            ["AWS/RDS", "ReadIOPS", "DBInstanceIdentifier", "${var.rds_instance_identifier}"],
            ["AWS/RDS", "WriteIOPS", "DBInstanceIdentifier", "${var.rds_instance_identifier}"],
          ]
          period = 300
          stat   = "Average"
          region = "us-east-1"
          title  = "RDS - Resource Utilization"
        }
      },
    ],
  })
}
