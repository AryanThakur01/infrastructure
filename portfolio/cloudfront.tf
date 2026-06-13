locals {
  s3_origin_id = "S3-${aws_s3_bucket.portfolio.id}"
  domains = {
    "staging"    = "staging.aryanthakur.dev",
    "production" = "aryanthakur.dev"
  }
  domain_name = local.domains[terraform.workspace]
}

// Use the managed caching policy for optimized caching of static assets
data "aws_cloudfront_cache_policy" "caching_optimized" {
  name = "Managed-CachingOptimized"
}

// 1. Create a CloudFront Function to rewrite extensionless paths to index.html for SPA routing
resource "aws_cloudfront_function" "spa_rewrite" {
  name    = "spa-rewrite"
  runtime = "cloudfront-js-2.0"
  comment = "Rewrite extensionless paths to index.html for SPA routing"
  publish = true
  code    = file("${path.module}/functions/spa-rewrite.js")
}

// 2. Create a CloudFront Origin Access Control to allow CloudFront to access the S3 bucket securely without making it public
resource "aws_cloudfront_origin_access_control" "portfolio_s3" {
  name                              = "portfolio-s3-access-control"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

// 3. Create a CloudFront distribution with the S3 bucket as the origin, using the CloudFront Function and Lambda@Edge function
resource "aws_cloudfront_distribution" "portfolio" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Portfolio CloudFront Distribution"
  default_root_object = "index.html"
  aliases             = [local.domain_name]
  price_class         = "PriceClass_200" # Use the lowest price class for global coverage

  origin {
    origin_id                = local.s3_origin_id
    domain_name              = aws_s3_bucket.portfolio.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.portfolio_s3.id
  }

  default_cache_behavior {
    cached_methods         = ["GET", "HEAD"]
    allowed_methods        = ["GET", "HEAD"]
    viewer_protocol_policy = "redirect-to-https"
    target_origin_id       = local.s3_origin_id

    cache_policy_id = data.aws_cloudfront_cache_policy.caching_optimized.id

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.spa_rewrite.arn
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.portfolio.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}
