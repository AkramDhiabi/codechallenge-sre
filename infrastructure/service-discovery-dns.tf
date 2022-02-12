resource "aws_service_discovery_private_dns_namespace" "superb-backend" {
  name        = "local"
  description = "superb-backend"
  vpc         = aws_vpc.main.id
}