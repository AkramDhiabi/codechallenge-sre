output "frontend_url" {
  value       = aws_route53_record.superb_frontend.fqdn
  description = "The frontend URL"
}