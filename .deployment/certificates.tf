##############################
#### Certificate frontend #####
##############################

resource "aws_acm_certificate" "frontend" {
  provider                  = aws
  domain_name               = var.lb_dns_record_frontend
  subject_alternative_names = [ "*.${var.lb_dns_record_frontend}" ]
  validation_method         = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "default" {
  provider                = aws
  certificate_arn         = aws_acm_certificate.frontend.arn
  validation_record_fqdns = [ for record in aws_route53_record.validation : record.fqdn ]
}