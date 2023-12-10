# modules/networking/main.tf
# resources: VPC, Subnets, IGW, NAT GW, ALB

# Create custom VPC that we will use for this lab
resource "aws_vpc" "lab-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Lab-vpc"
  }
}

# Create internet gateway - since this is custom vpc
resource "aws_internet_gateway" "lab-igw" {
  vpc_id = aws_vpc.lab-vpc.id
}

# Create Elastic IPs for NAT gateways
resource "aws_eip" "lab_nat_eip_a" {
}

resource "aws_eip" "lab_nat_eip_b" {
}


# Create NAT gateways in public subnets
resource "aws_nat_gateway" "lab_nat_gateway_a" {
  allocation_id = aws_eip.lab_nat_eip_a.id
  subnet_id     = aws_subnet.lab-public-subnets[0].id  # Specify the public subnet where the NAT gateway should be created
}

resource "aws_nat_gateway" "lab_nat_gateway_b" {
  allocation_id = aws_eip.lab_nat_eip_b.id
  subnet_id     = aws_subnet.lab-public-subnets[1].id  # Specify the public subnet where the NAT gateway should be created
}

# Create route table for private subnetss - NAT for internet access
resource "aws_route_table" "private_route_table_a" {
  vpc_id = aws_vpc.lab-vpc.id

  route {
    cidr_block        = "0.0.0.0/0"
    nat_gateway_id    = aws_nat_gateway.lab_nat_gateway_a.id
  }
}

resource "aws_route_table" "private_route_table_b" {
  vpc_id = aws_vpc.lab-vpc.id

  route {
    cidr_block        = "0.0.0.0/0"
    nat_gateway_id    = aws_nat_gateway.lab_nat_gateway_b.id
  }
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

# Create public subnets
resource "aws_subnet" "lab-public-subnets" {
  count                   = 2
  vpc_id                  = aws_vpc.lab-vpc.id
  cidr_block              = count.index == 0 ? "10.0.1.0/24" : "10.0.2.0/24"
  availability_zone       = count.index == 0 ? var.az-a : var.az-b
  map_public_ip_on_launch = true  # Make both subnets public

  tags = {
    Name = "Public-Subnet-${count.index + 1}"
  }
}

# Create private subnets for instances
resource "aws_subnet" "lab-private-subnets" {
  count                   = 2
  vpc_id                  = aws_vpc.lab-vpc.id
  cidr_block              = count.index == 0 ? "10.0.3.0/24" : "10.0.4.0/24"
  availability_zone       = count.index == 0 ? var.az-a : var.az-b
  map_public_ip_on_launch = false  # Make both subnets private

  tags = {
    Name = "Private-Subnet-${count.index + 1}"
  }
}

# Create private subnets for rds
resource "aws_subnet" "lab-private-subnets-rds" {
  count                   = 2
  vpc_id                  = aws_vpc.lab-vpc.id
  cidr_block              = count.index == 0 ? "10.0.5.0/28" : "10.0.6.0/28"
  availability_zone       = count.index == 0 ? var.az-a : var.az-b
  map_public_ip_on_launch = false  # Make both subnets private

  tags = {
    Name = "RDS-Private-Subnet-${count.index + 1}"
  }
}

# Associate private route table A with private subnet A
resource "aws_route_table_association" "private_subnet_association_a" {
  subnet_id      = aws_subnet.lab-private-subnets[0].id
  route_table_id = aws_route_table.private_route_table_a.id
}

# Associate private route table B with private subnet B
resource "aws_route_table_association" "private_subnet_association_b" {
  subnet_id      = aws_subnet.lab-private-subnets[1].id
  route_table_id = aws_route_table.private_route_table_b.id
}


# Associate public route table with public subnets
resource "aws_route_table_association" "lab-public-subnet-association" {
  count          = 2
  subnet_id      = aws_subnet.lab-public-subnets[count.index].id
  route_table_id = aws_route_table.lab-public-route-table[count.index].id
}

# Application Load Balancer configurations

# Create security group for alb
resource "aws_security_group" "lab-sg-alb" {
  name        = "alb-sg"
  description = "Security group for application load balancer"
  vpc_id      = aws_vpc.lab-vpc.id

  ingress {
    description = "Allow http user traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow user traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow everything"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

# Create security group for asg instances 
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

  egress {
    description = "Code deploy https handshake"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "RDS connection handshake"
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "health check reply"
    from_port = 3000
    to_port = 3000
    protocol = "tcp"
    security_groups = [aws_security_group.lab-sg-alb.id]
  }
    
}

# Create Application load balancer 
resource "aws_lb" "lab-alb" {
  name               = "lab-application-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lab-sg-alb.id]
  subnets            = [aws_subnet.lab-public-subnets[0].id, aws_subnet.lab-public-subnets[1].id]
  enable_deletion_protection = false
  depends_on = [aws_internet_gateway.lab-igw]
}

# Create target group ALB will route traffic
resource "aws_lb_target_group" "lab-alb-tg" {
  name        = "lab-target-group"
  port        = 3000
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.lab-vpc.id

# my node app replies HTTP "200" on /health path
  health_check {
    interval            = 15
    path                = "/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

}


# Create listener for alb on port 80
resource "aws_lb_listener" "lab-alb-lsnr" {
  load_balancer_arn = aws_lb.lab-alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lab-alb-tg.arn
  }
}

# Create listener for alb on port 443 + specify certificate
resource "aws_lb_listener" "lab-alb-lsnr-https" {
  load_balancer_arn = aws_lb.lab-alb.arn
  port              = 443
  protocol          = "HTTPS"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lab-alb-tg.arn
  }

  certificate_arn = "arn:aws:acm:us-east-1:656967617759:certificate/214eea2a-beec-410c-870d-05321f23ab1e"  # Replace with your ACM certificate ARN
}



