output "bucket_id" {
  description = "The name of the S3 bucket."
  value       = aws_s3_bucket.this.id
}

output "bucket_arn" {
  description = "The ARN of the S3 bucket. Pass this to the s3_oac policy module."
  value       = aws_s3_bucket.this.arn
}

output "bucket_regional_domain_name" {
  description = "The regional domain name of the bucket (e.g. my-bucket.s3.ap-south-1.amazonaws.com). Pass this to the CloudFront module as bucket_regional_domain_name."
  value       = aws_s3_bucket.this.bucket_regional_domain_name
}
