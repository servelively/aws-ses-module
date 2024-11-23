output "smtp_username" {
  description = "SMTP username for SES"
  value       = aws_iam_access_key.smtp_user_access_key.id
}

output "smtp_password" {
  description = "SMTP password for SES"
  value       = base64encode(aws_iam_access_key.smtp_user_access_key.secret)
  sensitive   = true
}

output "smtp_endpoint" {
  description = "SMTP endpoint for SES"
  value       = data.aws_ses_account.current.smtp_endpoint
}
