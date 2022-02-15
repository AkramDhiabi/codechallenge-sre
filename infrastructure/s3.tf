############# Frontend S3 bucket ##################
resource "aws_s3_bucket" "superb_bucket" {
  bucket = "${local.prefix}-superb-frontend"
  # files on this bucket are private
  #acl = "private"
  # destroy our bucket with our terraform
  force_destroy = true
}

locals {
  frontend_s3_origin_id = "${local.prefix}-frontend-S3Origin"
}

# define the policy for origin access identity to frontend cdn
data "aws_iam_policy_document" "s3_oai_frontend_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.superb_bucket.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.superb_frontend_oai.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "superb_frontend_policy" {
  bucket = aws_s3_bucket.superb_bucket.id
  policy = data.aws_iam_policy_document.s3_oai_frontend_policy.json
}