output "alb_dns_name" {
  description = "Public URL of the application (via the Application Load Balancer)"
  value       = "http://${aws_lb.app.dns_name}"
}

output "ec2_public_ip" {
  description = "Public IP of the app server (for SSH/debugging)"
  value       = aws_instance.app.public_ip
}

output "rds_endpoint" {
  description = "RDS PostgreSQL endpoint (private - only reachable from the EC2 instance)"
  value       = aws_db_instance.postgres.endpoint
}

output "s3_bucket_name" {
  description = "S3 bucket used for avatar storage"
  value       = aws_s3_bucket.avatars.bucket
}
