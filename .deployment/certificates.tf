###############################
#### Certificate validation ###
###############################

resource "aws_acm_certificate_validation" "frontend" {
  provider                = aws
  certificate_arn         = aws_acm_certificate.frontend.arn
  validation_record_fqdns = [ for record in aws_route53_record.validation_frontend : record.fqdn ]
}

resource "aws_acm_certificate_validation" "ipfs" {
  provider                = aws
  certificate_arn         = aws_acm_certificate.ipfs.arn
  validation_record_fqdns = [ for record in aws_route53_record.validation_ipfs : record.fqdn ]
}

resource "aws_acm_certificate_validation" "ipfs-admin" {
  provider                = aws
  certificate_arn         = aws_acm_certificate.ipfs-admin.arn
  validation_record_fqdns = [ for record in aws_route53_record.validation_ipfs_admin : record.fqdn ]
}

resource "aws_acm_certificate_validation" "backend" {
  provider                = aws
  certificate_arn         = aws_acm_certificate.backend.arn
  validation_record_fqdns = [ for record in aws_route53_record.validation_backend : record.fqdn ]
}

# resource "aws_acm_certificate_validation" "chainlink" {
#   provider                = aws
#   certificate_arn         = aws_acm_certificate.chainlink.arn
#   validation_record_fqdns = [ for record in aws_route53_record.validation_chainlink : record.fqdn ]
# }

###############################
#### Certificate frontend #####
###############################

resource "aws_acm_certificate" "frontend" {
  provider                  = aws
  domain_name               = var.lb_dns_record_frontend
  subject_alternative_names = [ "*.${var.lb_dns_record_frontend}" ]
  validation_method         = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

###############################
#### Certificate ipfs #########
###############################

resource "aws_acm_certificate" "ipfs" {
  provider                  = aws
  domain_name               = var.lb_dns_record_ipfs
  subject_alternative_names = [ "*.${var.lb_dns_record_ipfs}" ]
  validation_method         = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate" "ipfs-admin" {
  provider                  = aws
  domain_name               = var.lb_dns_record_ipfs_admin
  subject_alternative_names = [ "*.${var.lb_dns_record_ipfs_admin}" ]
  validation_method         = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

###############################
#### Certificate backend #####
###############################

resource "aws_acm_certificate" "backend" {
  provider                  = aws
  domain_name               = var.lb_dns_record_backend
  subject_alternative_names = [ "*.${var.lb_dns_record_backend}" ]
  validation_method         = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}