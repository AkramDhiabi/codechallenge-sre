############### Frontend CloudFront distribution ################
resource "aws_cloudfront_origin_access_identity" "superb_frontend_oai" {
  comment = "${local.prefix}-superb-frontend-oai"
}

resource "aws_cloudfront_distribution" "fstg_cdn" {
  origin {
    domain_name = aws_s3_bucket.superb_bucket.bucket_regional_domain_name
    origin_id   = local.frontend_s3_origin_id

    origin_path = "/${local.prefix}"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.superb_frontend_oai.cloudfront_access_identity_path
    }
  }

  enabled         = true
  is_ipv6_enabled = true

  default_root_object = "index.html"

  aliases = [ "client.${var.dns_zone_name}"]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.frontend_s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
    acm_certificate_arn            = "${var.acm_arn_prod}"
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2019"
  }

  tags = local.common_tags
}