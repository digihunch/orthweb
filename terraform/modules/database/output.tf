output "db_info" {
  value = {
    db_endpoint = aws_db_instance.postgres.endpoint  
  }
}
