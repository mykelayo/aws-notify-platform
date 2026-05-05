output "cluster_arn" {
  description = "ARN of Aurora cluster"
  value       = aws_rds_cluster.aurora.arn
}

output "cluster_endpoint" {
  description = "Cluster endpoint (read/write)"
  value       = aws_rds_cluster.aurora.endpoint
}

output "security_group_id" {
  description = "Security group ID of Aurora"
  value       = aws_security_group.aurora.id
}

output "database_name" {
  description = "Database name"
  value       = var.database_name
}