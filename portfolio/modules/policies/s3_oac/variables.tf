variable "cloudfront_distribution_arn" {
  description = "The ARN of the CloudFront distribution that will access the S3 bucket."
  type        = string
  default     = ""
}
variable "bucket_arn" {
  description = "The ARN of the S3 bucket."
  type        = string
  default     = ""
}
