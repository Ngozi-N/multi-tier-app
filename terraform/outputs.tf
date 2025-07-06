output "jenkins_public_ip" {
  description = "Public IP of the Jenkins server."
  value       = aws_instance.jenkins_server.public_ip
}

output "frontend_alb_dns_name" {
  description = "DNS name of the Frontend Application Load Balancer."
  value       = aws_lb.frontend_alb.dns_name
}

output "backend_alb_dns_name" {
  description = "DNS name of the Backend Application Load Balancer."
  value       = aws_lb.backend_alb.dns_name
}

output "rds_endpoint" {
  description = "Endpoint of the RDS database."
  value       = aws_db_instance.main_db.address
}

output "grafana_public_ip" {
  description = "Public IP of the Grafana server."
  value       = aws_instance.monitoring_server.public_ip
}