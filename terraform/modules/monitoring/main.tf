resource "aws_cloudwatch_dashboard" "lab-dashboard" {
  depends_on = [ var.asg_id ]
  dashboard_name = "Lab-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

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
        type   = "text"
        x      = 0
        y      = 7
        width  = 3
        height = 3

        properties = {
          markdown = "My Lab Dashboard for instances and ALB"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6

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
        type   = "metric"
        x      = 0
        y      = 12
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", "${var.alb_arn}"],
            ["AWS/ApplicationELB", "HTTPCode_Target_2XX_Count", "LoadBalancer", "${var.alb_arn}"],
            ["AWS/ApplicationELB", "HTTPCode_Target_4XX_Count", "LoadBalancer", "${var.alb_arn}"],
            ["AWS/ApplicationELB", "HTTPCode_Target_5XX_Count", "LoadBalancer", "${var.alb_arn}"],
          ],
          period = 300,
          stat   = "Sum",
          region = "us-east-1",
          title  = "ALB - Request and HTTP Code Counts",
        },
      },
     ]
  })
}
