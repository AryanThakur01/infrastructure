variable "name" {
  type        = string
  description = "Unique name for this distribution. Used to name the OAC and response headers policy."
}

# --- S3 Origin ---

variable "bucket_regional_domain_name" {
  type        = string
  description = "The regional domain name of the S3 bucket (e.g. my-bucket.s3.ap-south-1.amazonaws.com). Use the bucket's regional domain, not the website endpoint."
}

variable "bucket_id" {
  type        = string
  description = "The ID (name) of the S3 bucket. Used as the CloudFront origin ID."
}

# --- Routing ---

variable "default_root_object" {
  type        = string
  description = "The file CloudFront returns when a request hits the root URL."
  default     = "index.html"
}

variable "enable_spa_routing" {
  type        = bool
  description = "Redirect 403 and 404 S3 errors to /index.html with a 200 response. Enables client-side routing for React, Vue, and similar SPAs."
  default     = false
}

variable "custom_error_responses" {
  type = list(object({
    error_code            = number
    response_code         = number
    response_page_path    = string
    error_caching_min_ttl = optional(number, 10)
  }))
  description = "Custom error response rules. Cannot be used together with enable_spa_routing — use one or the other."
  default     = []
}

# --- Custom Domain ---

variable "aliases" {
  type        = list(string)
  description = "Custom domain names for the distribution (e.g. [\"cdn.example.com\"]). Requires acm_certificate_arn."
  default     = []
}

variable "acm_certificate_arn" {
  type        = string
  description = "ARN of the ACM certificate to use for HTTPS on custom domains. IMPORTANT: the certificate must be in us-east-1 regardless of your primary region — this is an AWS requirement for CloudFront."
  default     = null
}

# --- Performance & Cost ---

variable "price_class" {
  type        = string
  description = "Controls which edge locations serve your content. PriceClass_100 = US/EU/Canada (cheapest). PriceClass_200 adds Asia/Middle East/Africa. PriceClass_All = every edge location."
  default     = "PriceClass_100"

  validation {
    condition     = contains(["PriceClass_100", "PriceClass_200", "PriceClass_All"], var.price_class)
    error_message = "price_class must be one of: PriceClass_100, PriceClass_200, PriceClass_All."
  }
}

# --- Geo Restriction ---

variable "geo_restriction_type" {
  type        = string
  description = "Type of geo restriction. 'none' disables it. 'whitelist' allows only listed countries. 'blacklist' blocks listed countries."
  default     = "none"

  validation {
    condition     = contains(["none", "whitelist", "blacklist"], var.geo_restriction_type)
    error_message = "geo_restriction_type must be one of: none, whitelist, blacklist."
  }
}

variable "geo_restriction_locations" {
  type        = list(string)
  description = "ISO 3166-1 alpha-2 country codes to whitelist or blacklist. Only used when geo_restriction_type is not 'none'."
  default     = []
}

# --- Logging ---

variable "logging_bucket_domain_name" {
  type        = string
  description = "The domain name of the S3 bucket to write access logs to (e.g. my-logs-bucket.s3.amazonaws.com). The bucket must have ACLs enabled. Leave null to disable logging."
  default     = null
}

variable "logging_prefix" {
  type        = string
  description = "Prefix for CloudFront access log files in the logging bucket."
  default     = "cloudfront/"
}

# --- Tags ---

variable "tags" {
  type        = map(string)
  description = "Tags applied to the CloudFront distribution."
  default     = {}
}
