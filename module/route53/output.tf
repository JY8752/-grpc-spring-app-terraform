output "acm_certificate_arn" {
  value = aws_acm_certificate.default.arn
}

output "acm_certificate" {
  value = aws_acm_certificate.default
}
