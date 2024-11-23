provider "aws" {
  region = var.region
}

# Verify a domain
resource "aws_ses_domain_identity" "domain" {
  domain = var.domain_name
}

# SES Domain DKIM
resource "aws_ses_domain_dkim" "dkim" {
  domain = aws_ses_domain_identity.domain.domain
}

# Domain Verification Records
resource "aws_route53_record" "domain_verification" {
  for_each = aws_ses_domain_identity.domain.verification_token

  zone_id = var.route53_zone_id
  name    = each.value
  type    = "TXT"
  ttl     = 300
  records = [each.key]
}

# DKIM Records
resource "aws_route53_record" "dkim_records" {
  for_each = toset(aws_ses_domain_dkim.dkim_tokens)

  zone_id = var.route53_zone_id
  name    = "${each.value}._domainkey.${aws_ses_domain_identity.domain.domain}"
  type    = "CNAME"
  ttl     = 300
  records = ["${each.value}.amazonses.com"]
}

# Verify the domain
resource "aws_ses_domain_identity_verification" "verify" {
  domain = aws_ses_domain_identity.domain.domain

  depends_on = [aws_route53_record.domain_verification]
}

# IAM Role for SMTP user
resource "aws_iam_user" "smtp_user" {
  name = var.smtp_user_name
}

resource "aws_iam_user_policy" "smtp_user_policy" {
  name   = "SesSMTPAccess"
  user   = aws_iam_user.smtp_user.name
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "ses:SendRawEmail",
        Resource = "*"
      }
    ]
  })
}

# Access Key for SMTP User
resource "aws_iam_access_key" "smtp_user_access_key" {
  user = aws_iam_user.smtp_user.name
}

# Output SMTP Credentials
data "aws_ses_account" "current" {}

output "smtp_credentials" {
  value = {
    smtp_username = aws_iam_access_key.smtp_user_access_key.id
    smtp_password = base64encode(aws_iam_access_key.smtp_user_access_key.secret)
    smtp_endpoint = data.aws_ses_account.current.smtp_endpoint
  }
  sensitive = true
}
