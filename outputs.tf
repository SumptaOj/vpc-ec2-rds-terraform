output "database_endpoint" {
  description = "The endpoint of the database"
  value       = aws_db_instance.rds.address
}

output "database_port" {
  description = "The port of the database"
  value       = aws_db_instance.rds.port
}

output "rds_username" {
  description = "RDS instance root username"
  value       = aws_db_instance.rds.username
  sensitive   = true
}

output "launch_template_id" {
  description = "Launch Template ID"
  value       = aws_launch_template.web.id
}

output "autoscaling_group_id" {
  description = "Autoscaling Group ID"
  value       = aws_autoscaling_group.web.id
}

output "autoscaling_group_arn" {
  description = "Autoscaling Group ARN"
  value       = aws_autoscaling_group.web.arn
}

output "autoscaling_group_name" {
  description = "Autoscaling Group Name"
  value       = aws_autoscaling_group.web.name
}