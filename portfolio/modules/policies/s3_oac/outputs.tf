output "s3_bucket_oac_policy" {
  description = "The IAM policy document that grants CloudFront OAC access to the S3 bucket."
  value       = data.aws_iam_policy_document.oac.json
}
