provider "aws" {
  region = "us-east-1"
  alias  = "us_east_1"
}

// 1. Create an ACM certificate for the domain and its subdomains in the us-east-1 region
resource "aws_acm_certificate" "portfolio" {
  provider          = aws.us_east_1
  domain_name       = "aryanthakur.dev"
  validation_method = "DNS"

  subject_alternative_names = [
    "www.aryanthakur.dev",
  ]

  lifecycle {
    create_before_destroy = true
  }
}

// 2. Gate: blo
resource "aws_acm_certificate_validation" "name" {
  provider        = aws.us_east_1
  certificate_arn = aws_acm_certificate.portfolio.arn
  validation_record_fqdns = [
    for r in aws_acm_certificate.portfolio.domain_validation_options : r.resource_record_name
  ]
}

// 3. Output the ACM validation records for DNS configuration
output "acm_validation_records" {
  value = aws_acm_certificate.portfolio.domain_validation_options
}
