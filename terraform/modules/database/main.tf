# modules/database/main.tf
# resources: RDS multi-az instance

# Security group for rds instance
resource "aws_security_group" "lab-mysql-db-sg" {
  name        = "lab-mysql-rds-sg"
  description = "Security group for lab-mysql-db instance"
  vpc_id      = var.vpc_id

  ingress {
    description     = "mysql access from ec2"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.sg_asg_id]
  }

    tags = {
    Name = "lab-mysql-rds-sg"
  }
}

# Subnet group for rds
resource "aws_db_subnet_group" "lab-mysql-db-subnet-group" {
  name        = "lab-mysql-db-subnet-group"
  subnet_ids  = var.subnet_ids
  description = "Subnets for rds instance"
}

resource "aws_db_instance" "lab-mysql-db" {
  allocated_storage      = 10
  db_name                = "my_node"
  engine                 = "mysql"
  engine_version         = "5.7"
  multi_az               = true
  identifier             = "lab-mysql-db"
  instance_class         = "db.t3.micro"
  username               = "admin"
  password               = "admin123"
  db_subnet_group_name   = aws_db_subnet_group.lab-mysql-db-subnet-group.id
  vpc_security_group_ids = [aws_security_group.lab-mysql-db-sg.id]
  parameter_group_name   = "default.mysql5.7"
  skip_final_snapshot    = true
}

