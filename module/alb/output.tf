output "alb_dns_name" {
  value = aws_alb.default.dns_name
}

output "alb_zone_id" {
  value = aws_alb.default.zone_id
}