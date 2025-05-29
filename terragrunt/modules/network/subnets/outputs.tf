output "private_subnet_a" {
  description = "The ID of the private subnet in availability zone A"
  value       = aws_subnet.private_subnet["eu-west-1a"].id
  
}

output "private_subnet_b" {
  description = "The ID of the private subnet in availability zone B"
  value       = aws_subnet.private_subnet["eu-west-1b"].id
  
}