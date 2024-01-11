output "db_instance_endpoint" {
  value = aws_db_instance.database.endpoint
}

output "db_identifier" {
  value = aws_db_instance.database.identifier
}

output "db_username" {
  value = aws_db_instance.database.username
}

output "db_password" {
  value = aws_db_instance.database.password
  sensitive = true
}
