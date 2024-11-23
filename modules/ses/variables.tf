variable "region" {
  description = "The AWS region where SES should be set up"
  type        = string
  default     = "us-east-1"
}

variable "domain_name" {
  description = "The domain to verify with SES for sending emails"
  type        = string
}

variable "route53_zone_id" {
  description = "The Route 53 Zone ID for managing DNS records"
  type        = string
}

variable "smtp_user_name" {
  description = "Name of the IAM user for SES SMTP access"
  type        = string
  default     = "ses-smtp-user"
}
