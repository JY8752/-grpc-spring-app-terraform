#ドメインの登録はコンソールから
data "aws_route53_zone" "default" {
  name = var.input.domain
}

#ALBのDNSレコードの定義
resource "aws_route53_record" "default" {
  zone_id = data.aws_route53_zone.default.zone_id
  name    = data.aws_route53_zone.default.name
  type    = "A" #ALIASレコード
  alias {
    name                   = var.dns_name
    zone_id                = var.zone_id
    evaluate_target_health = true
  }
}

#SSL証明書の定義
resource "aws_acm_certificate" "default" {
  domain_name               = aws_route53_record.default.name
  subject_alternative_names = [] #ドメイン名の追加
  validation_method         = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

#SSL証明書の検証用レコードの定義
resource "aws_route53_record" "certificate" {
  for_each = {
    for dvo in aws_acm_certificate.default.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  zone_id = data.aws_route53_zone.default.id
  ttl     = 60
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
}

#検証の待機
resource "aws_acm_certificate_validation" "default" {
  certificate_arn         = aws_acm_certificate.default.arn
  validation_record_fqdns = [for record in aws_route53_record.certificate : record.fqdn]
}
