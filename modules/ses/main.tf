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

# DKIM Records
resource "aws_route53_record" "domain_verification" {
  count   = 3
  zone_id = var.route53_zone_id
  name    = "${aws_ses_domain_dkim.dkim.dkim_tokens[count.index]}._domainkey"
  type    = "CNAME"
  ttl     = "600"
  records = ["${aws_ses_domain_dkim.dkim.dkim_tokens[count.index]}.dkim.amazonses.com"]
}


resource "aws_route53_record" "amazonses_verification_record" {
  zone_id = var.route53_zone_id
  name    = "_amazonses.${aws_ses_domain_identity.domain.id}"
  type    = "TXT"
  ttl     = "600"
  records = [aws_ses_domain_identity.domain.verification_token]
}

resource "aws_ses_domain_identity_verification" "verification" {
  domain = aws_ses_domain_identity.domain.id

  depends_on = [aws_route53_record.amazonses_verification_record]
}

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