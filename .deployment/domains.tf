########################
#### Route53       #####
########################

data "aws_route53_zone" "frenchbtc-fr" {
  name = var.dns_zone_name
}

resource "aws_route53_record" "validation" {
  for_each = {
    for dvo in aws_acm_certificate.backend.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true

  zone_id   = data.aws_route53_zone.frenchbtc-fr.zone_id
  name      = each.value.name
  type      = each.value.type
  records   = [ each.value.record ]
  ttl       = 10
}

resource "aws_route53_record" "backend" {
  zone_id = data.aws_route53_zone.frenchbtc-fr.zone_id
  name    = var.lb_dns_record_backend
  type    = "CNAME"
  ttl     = "10"
  records = [ aws_lb.backend.dns_name ]
}