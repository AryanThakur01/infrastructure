output "distribution_id" {
  description = "The CloudFront distribution ID. Used to create invalidations or reference the distribution in other resources."
  value       = aws_cloudfront_distribution.this.id
}

output "distribution_arn" {
  description = "The ARN of the CloudFront distribution. Pass this to the s3_oac policy module to scope bucket access to this distribution only."
  value       = aws_cloudfront_distribution.this.arn
}

output "distribution_domain_name" {
  description = "The CloudFront domain name (e.g. d1234abcd.cloudfront.net). Use this as a CNAME target when setting up DNS."
  value       = aws_cloudfront_distribution.this.domain_name
}

output "distribution_hosted_zone_id" {
  description = "The CloudFront hosted zone ID. Use this with Route 53 alias records instead of a raw CNAME."
  value       = aws_cloudfront_distribution.this.hosted_zone_id
}

output "oac_id" {
  description = "The ID of the Origin Access Control attached to this distribution."
  value       = aws_cloudfront_origin_access_control.this.id
}
