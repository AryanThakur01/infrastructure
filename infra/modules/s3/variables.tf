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
  description = "JSON bucket policy to attach. Leave null to attach no policy."
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the bucket. Use this to pass environment, project, owner, etc."
  default     = {}
}
