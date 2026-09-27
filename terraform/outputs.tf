output "public_ip" {
  description = "EC2 public IP"
  value       = aws_instance.ecommerce.public_ip
}

output "public_dns" {
  description = "EC2 public DNS"
  value       = aws_instance.ecommerce.public_dns
}

output "application_url" {
  description = "Public frontend URL"
  value       = "http://${aws_instance.ecommerce.public_ip}:3000"
}

output "api_status_url" {
  description = "Frontend endpoint that verifies all four backend services"
  value       = "http://${aws_instance.ecommerce.public_ip}:3000/api-status"
}
