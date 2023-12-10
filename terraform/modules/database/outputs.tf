# modules/database/outputs.tf

output "rds_endpoint" {
  value = aws_db_instance.lab-mysql-db.endpoint
}

output "rds_dependency" {
  value = aws_db_instance.lab-mysql-db
}
