locals {
  site_domain  = "garrettleber.com"
  s3_origin_id = "S3-${local.site_domain}"
}

resource "aws_s3_bucket" "website_bucket" {
  bucket = local.site_domain
  acl    = "public-read"
  website {
    index_document = "index.html"
  }
}

resource "aws_s3_bucket_policy" "website_bucket" {
  bucket = aws_s3_bucket.website_bucket.id
  policy = jsonencode({
    Id = "PolicyForCloudFrontPrivateContent"
    Statement = [{
      Action = "s3:GetObject"
      Effect = "Allow"
      Principal = {
        AWS = aws_cloudfront_origin_access_identity.main.iam_arn
      }
      Resource = "${aws_s3_bucket.website_bucket.arn}/*"
      Sid      = "1"
    }, ]
    Version = "2008-10-17"
  })
}

resource "aws_route53_zone" "website_zone" {
  name = local.site_domain
}

resource "aws_route53_record" "main" {
  zone_id = aws_route53_zone.website_zone.zone_id
  name    = local.site_domain
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.main.domain_name
    zone_id                = aws_cloudfront_distribution.main.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_cloudfront_distribution" "main" {
  enabled             = true
  aliases             = [aws_s3_bucket.website_bucket.bucket]
  default_root_object = "index.html"
  is_ipv6_enabled     = true

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    default_ttl            = 0
    max_ttl                = 0
    target_origin_id       = local.s3_origin_id
    viewer_protocol_policy = "redirect-to-https"
    forwarded_values {
      query_string = false
      cookies {
        forward           = "none"
        whitelisted_names = []
      }
    }
  }

  origin {
    domain_name = aws_s3_bucket.website_bucket.bucket_domain_name
    origin_id   = local.s3_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.main.cloudfront_access_identity_path
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.website_certificate.arn
    minimum_protocol_version = "TLSv1.2_2019"
    ssl_support_method       = "sni-only"
  }
}

resource "aws_cloudfront_origin_access_identity" "main" {
  comment = "OAI to allow CloudFront distribution access to website S3 Bucket"
}

resource "aws_acm_certificate" "website_certificate" {
  domain_name       = local.site_domain
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}
