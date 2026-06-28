locals {
  domain = "aryanthakur.dev"
}

# Hosted zone for the domain
resource "aws_route53_zone" "main" {
  name = local.domain
}

# Apex -> CloudFront (native alias, geo-aware, no flattening)
resource "aws_route53_record" "apex" {
  zone_id = aws_route53_zone.main.zone_id
  name    = local.domain
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.portfolio.domain_name
    zone_id                = aws_cloudfront_distribution.portfolio.hosted_zone_id
    evaluate_target_health = false
  }
}

# www -> CloudFront (same distro)
resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "www.${local.domain}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.portfolio.domain_name
    zone_id                = aws_cloudfront_distribution.portfolio.hosted_zone_id
    evaluate_target_health = false
  }
}

# IPv6 — add these too since CloudFront serves AAAA and clients prefer it
resource "aws_route53_record" "apex_aaaa" {
  zone_id = aws_route53_zone.main.zone_id
  name    = local.domain
  type    = "AAAA"

  alias {
    name                   = aws_cloudfront_distribution.portfolio.domain_name
    zone_id                = aws_cloudfront_distribution.portfolio.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "www_aaaa" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "www.${local.domain}"
  type    = "AAAA"

  alias {
    name                   = aws_cloudfront_distribution.portfolio.domain_name
    zone_id                = aws_cloudfront_distribution.portfolio.hosted_zone_id
    evaluate_target_health = false
  }
}

# Output the nameservers to paste into Namecheap
output "route53_nameservers" {
  value = aws_route53_zone.main.name_servers
}
