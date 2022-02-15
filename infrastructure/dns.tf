# get dns hosted zone for superb
data "aws_route53_zone" "superb_zone" {
  name = var.dns_zone_name
}

# get issued certificate
data "aws_acm_certificate" "superb_issued" {
  domain   = var.dns_zone_name
  types    = ["AMAZON_ISSUED"]
  statuses = ["ISSUED"]
} 

# create a route53 record for api lb dns
resource "aws_route53_record" "graphql" {
  zone_id = data.aws_route53_zone.superb_zone.zone_id
  name    = "superb-graphql.${var.dns_zone_name}"
  # link it to CNAME which points to another DNS name of the load balancer
  type = "CNAME"
  # 5 min do propagate dns service
  ttl     = "300"
  records = [aws_lb.graphql_api.dns_name]
}

# create a route53 record for frontend cdn
resource "aws_route53_record" "superb_frontend" {
  zone_id = data.aws_route53_zone.superb_zone.zone_id
  name    = "client-superb.${var.dns_zone_name}"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_cloudfront_distribution.superb_cdn.domain_name]
}