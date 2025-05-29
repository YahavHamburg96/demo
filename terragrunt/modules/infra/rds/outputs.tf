output "rds_endpoint" {
  value = aws_db_instance.postgres.endpoint
}

output "db_secret_arn" {
  value = aws_secretsmanager_secret.db_secret.arn
}

output "db_secret_value" {
  value = random_password.db_password.result
  sensitive = true
}

