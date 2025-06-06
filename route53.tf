# Dev Configuration (uncomment when working on Dev)
# data "aws_route53_zone" "app_zone" {
#   zone_id = var.hosted_zone_ids["dev"]
# }

# resource "aws_route53_record" "app_alb" {
#   zone_id = data.aws_route53_zone.app_zone.zone_id
#   name    = "dev.onerahul.me"
#   type    = "A"
#   alias {
#     name                   = aws_lb.app_alb.dns_name
#     zone_id                = aws_lb.app_alb.zone_id
#     evaluate_target_health = true
#   }
# }

# Demo Configuration (uncomment when working on Demo)
data "aws_route53_zone" "app_zone" {
  zone_id = var.hosted_zone_ids["demo"]
}

resource "aws_route53_record" "app_alb" {
  zone_id = data.aws_route53_zone.app_zone.zone_id
  name    = "demo.onerahul.me"
  type    = "A"
  alias {
    name                   = aws_lb.app_alb.dns_name
    zone_id                = aws_lb.app_alb.zone_id
    evaluate_target_health = true
  }
}

# Certificate validation record for dev
resource "aws_route53_record" "cert_validation" {
  for_each = var.environment == "dev" ? {
    for dvo in aws_acm_certificate.app_cert[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  } : {}

  zone_id = var.hosted_zone_ids["dev"]
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 60

}