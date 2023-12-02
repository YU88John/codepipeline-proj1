# modules/networking/main.tf

# Create VPC that we will use for this lab
resource "aws_vpc" "lab-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Lab-vpc"
  }
}

# Create subnets
resource "aws_subnet" "lab-subnets" {
  count                   = 2
  vpc_id                  = aws_vpc.lab-vpc.id
  cidr_block              = count.index == 0 ? "10.0.1.0/24" : "10.0.2.0/24"
  availability_zone       = count.index == 0 ? var.az-a : var.az-b
  map_public_ip_on_launch = true

  tags = {
    Name = "Subnet-${count.index + 1}"
  }
}

# Create internet gateway - since this is custom vpc
resource "aws_internet_gateway" "lab-igw" {
  vpc_id = aws_vpc.lab-vpc.id
}

# Create route table for public subnets
resource "aws_route_table" "lab-public-route-table" {
  count = 2
  vpc_id = aws_vpc.lab-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lab-igw.id
  }

  tags = {
    Name = "Public-Route-Table-${count.index + 1}"
  }
}

# Associate public route table with public subnets
resource "aws_route_table_association" "lab-public-subnet-association" {
  count          = 2
  subnet_id      = aws_subnet.lab-subnets[count.index].id
  route_table_id = aws_route_table.lab-public-route-table[count.index].id
}

# security group for alb
resource "aws_security_group" "lab-sg-alb" {
  name        = "alb-sg"
  description = "Security group for application load balancer"
  vpc_id      = aws_vpc.lab-vpc.id

  ingress {
    description = "Allow user traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

# security group for instances - asg launch template
resource "aws_security_group" "lab-asg-sg" {
  name = "asg-template-sg"
  description = "Security group for auto scaling group"
  vpc_id = aws_vpc.lab-vpc.id

  ingress {
    description = "allow alb traffic to node app"
    from_port = 3000
    to_port = 3000
    protocol = "tcp"
    security_groups = [aws_security_group.lab-sg-alb.id]
  }

  ingress {
    description = "allow alb traffic to node app"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    security_groups = [aws_security_group.lab-sg-alb.id]
  }

  ingress {
    description = "allow ssh access"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "allow ui access"
    from_port = 3000
    to_port = 3000
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    
}

// Create Application load balancer 
resource "aws_lb" "lab-alb" {
  name               = "lab-application-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lab-sg-alb.id]
  subnets            = [aws_subnet.lab-subnets[0].id, aws_subnet.lab-subnets[1].id]
  enable_deletion_protection = false
  depends_on = [aws_internet_gateway.lab-igw]
}

// Create target group ALB will hit
resource "aws_lb_target_group" "lab-alb-tg" {
  name        = "lab-target-group"
  port        = 3000
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.lab-vpc.id

  health_check {
    interval            = 30
    path = "/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

}


// Create listener for alb
resource "aws_lb_listener" "lab-alb-lsnr" {
  load_balancer_arn = aws_lb.lab-alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      status_code  = "200"
      message_body = "OK"
    }
  }
}

// Create listener rule which will match incoming traffic 
resource "aws_lb_listener_rule" "lab-alb-lsnr-rule" {
  listener_arn = aws_lb_listener.lab-alb-lsnr.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lab-alb-tg.arn
  }

  condition {
    path_pattern {
      values = ["/"]
    }
  }
}
