locals {
  use_custom_cert = length(var.aliases) > 0

  spa_error_responses = var.enable_spa_routing ? [
    {
      error_code            = 403
      response_code         = 200
      response_page_path    = "/index.html"
      error_caching_min_ttl = 10
    },
    {
      error_code            = 404
      response_code         = 200
      response_page_path    = "/index.html"
      error_caching_min_ttl = 10
    }
  ] : []

  all_error_responses = concat(local.spa_error_responses, var.custom_error_responses)
}

# --- AWS Managed Policies (data sources) ---

data "aws_cloudfront_cache_policy" "caching_optimized" {
  name = "Managed-CachingOptimized"
}

data "aws_cloudfront_origin_request_policy" "cors_s3" {
  name = "Managed-CORS-S3Origin"
}

# --- Origin Access Control ---
# OAC is the modern, more secure replacement for OAI. It uses short-lived
# SigV4 signatures instead of a long-lived credential attached to the bucket.

resource "aws_cloudfront_origin_access_control" "this" {
  name                              = var.name
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# --- Security Response Headers Policy ---
# Applied to every response. These headers are safe defaults for any static
# site. CSP is intentionally excluded — it's too app-specific to opine on.

resource "aws_cloudfront_response_headers_policy" "security" {
  name = "${var.name}-security-headers"

  security_headers_config {
    strict_transport_security {
      access_control_max_age_sec = 31536000 # 1 year
      include_subdomains         = true
      preload                    = true
      override                   = true
    }

    content_type_options {
      # Prevents browsers from MIME-sniffing away from the declared content-type.
      override = true
    }

    frame_options {
      frame_option = "DENY"
      override     = true
    }

    referrer_policy {
      referrer_policy = "strict-origin-when-cross-origin"
      override        = true
    }

    xss_protection {
      mode_block = true
      protection = true
      override   = true
    }
  }
}

# --- CloudFront Distribution ---

resource "aws_cloudfront_distribution" "this" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = var.name
  default_root_object = var.default_root_object
  price_class         = var.price_class
  aliases             = var.aliases
  tags                = var.tags

  origin {
    domain_name              = var.bucket_regional_domain_name
    origin_id                = "s3-${var.bucket_id}"
    origin_access_control_id = aws_cloudfront_origin_access_control.this.id
  }

  default_cache_behavior {
    target_origin_id       = "s3-${var.bucket_id}"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]

    cache_policy_id            = data.aws_cloudfront_cache_policy.caching_optimized.id
    origin_request_policy_id   = data.aws_cloudfront_origin_request_policy.cors_s3.id
    response_headers_policy_id = aws_cloudfront_response_headers_policy.security.id
  }

  dynamic "custom_error_response" {
    for_each = local.all_error_responses
    content {
      error_code            = custom_error_response.value.error_code
      response_code         = custom_error_response.value.response_code
      response_page_path    = custom_error_response.value.response_page_path
      error_caching_min_ttl = custom_error_response.value.error_caching_min_ttl
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = var.geo_restriction_type
      locations        = var.geo_restriction_locations
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = !local.use_custom_cert
    acm_certificate_arn            = local.use_custom_cert ? var.acm_certificate_arn : null
    ssl_support_method             = local.use_custom_cert ? "sni-only" : null
    minimum_protocol_version       = local.use_custom_cert ? "TLSv1.2_2021" : null
  }

  dynamic "logging_config" {
    for_each = var.logging_bucket_domain_name != null ? [1] : []
    content {
      bucket          = var.logging_bucket_domain_name
      prefix          = var.logging_prefix
      include_cookies = false
    }
  }

  lifecycle {
    precondition {
      condition     = !var.enable_spa_routing || length(var.custom_error_responses) == 0
      error_message = "Cannot use enable_spa_routing and custom_error_responses together. Use custom_error_responses directly for full control over error handling."
    }

    precondition {
      condition     = !local.use_custom_cert || var.acm_certificate_arn != null
      error_message = "acm_certificate_arn is required when aliases are set. The certificate must exist in us-east-1."
    }

    precondition {
      condition     = var.geo_restriction_type == "none" || length(var.geo_restriction_locations) > 0
      error_message = "geo_restriction_locations must not be empty when geo_restriction_type is 'whitelist' or 'blacklist'."
    }
  }
}
