output "public_subnet_ids" {
  description = "List of all public subnet IDs"
  value       = [for subnet in aws_subnet.public_subnet : subnet.id]
}

output "private_subnet_ids" {
  description = "List of all private subnet IDs"
  value       = [for subnet in aws_subnet.private_subnet : subnet.id]
}
