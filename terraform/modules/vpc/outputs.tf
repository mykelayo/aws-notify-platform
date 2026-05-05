output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = aws_subnet.private[*].id
}

output "nat_gateway_id" {
  description = "NAT Gateway ID (single in AZ-a)"
  value       = aws_nat_gateway.this.id
}

output "availability_zones" {
  description = "Availability zones used"
  value       = var.availability_zones
}

output "default_security_group_id" {
  description = "ID of VPC's default security group"
  value       = aws_vpc.this.default_security_group_id
}