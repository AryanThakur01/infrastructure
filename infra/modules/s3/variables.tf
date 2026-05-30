variable "bucket_name" {
  type        = string
  description = "Name of the S3 bucket. Must be globally unique across all AWS accounts."
}

variable "versioning_enabled" {
  type        = bool
  description = "Enable versioning on the bucket. Keeps old copies of objects on overwrite or delete."
  default     = true
}

variable "encryption_algorithm" {
  type        = string
  description = "Server-side encryption algorithm. AES256 for SSE-S3, aws:kms for SSE-KMS."
  default     = "AES256"

  validation {
    condition     = contains(["AES256", "aws:kms"], var.encryption_algorithm)
    error_message = "encryption_algorithm must be either AES256 or aws:kms."
  }
}

variable "kms_master_key_id" {
  type        = string
  description = "KMS key ID to use when encryption_algorithm is aws:kms. Leave null for AES256."
  default     = null
}

variable "block_public_access" {
  type        = bool
  description = "Block all public access to the bucket. Set to false only when public access is explicitly required."
  default     = true
}

variable "enable_website" {
  type        = bool
  description = "Enable static website hosting on this bucket."
  default     = false
}

variable "index_document" {
  type        = string
  description = "The file S3 serves when a request hits the root. Only used when enable_website is true."
  default     = "index.html"
}

variable "error_document" {
  type        = string
  description = "The file S3 serves on 4xx errors. Only used when enable_website is true."
  default     = "error.html"
}

variable "bucket_policy" {
  type        = string
  description = <<-EOT
    JSON bucket policy. Use aws_iam_policy_document and pass the 
    .json attribute. Do not pass raw JSON strings directly.
  EOT

  validation {
    condition     = var.bucket_policy == null || can(jsondecode(var.bucket_policy))
    error_message = "bucket_policy must be valid JSON or null."
  }

  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the bucket. Use this to pass environment, project, owner, etc."
  default     = {}
}

variable "force_destroy" {
  type        = bool
  description = "Whether to force destroy the bucket when deleting. If true, all objects (including versions) will be deleted. Use with caution."
  default     = false
}

variable "noncurrent_version_expiry_days" {
  type        = number
  default     = 30
  description = "Days before noncurrent object versions are expired. Only applies when versioning is enabled."
}

variable "enable_lifecycle_rule" {
  type        = bool
  default     = true
  description = "Enables noncurrent version expiry. Keep true even when suspending versioning to clean up existing versions."
}
