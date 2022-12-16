########################
#### Route53       #####
########################

data "aws_route53_zone" "frenchbtc-fr" {
  name = var.dns_zone_name
}

resource "aws_route53_record" "validation_frontend" {
  for_each = {
    for dvo in aws_acm_certificate.frontend.domain_validation_options : dvo.domain_name => {
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

resource "aws_route53_record" "validation_ipfs" {
  for_each = {
    for dvo in aws_acm_certificate.ipfs.domain_validation_options : dvo.domain_name => {
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

resource "aws_route53_record" "validation_ipfs_admin" { 
  for_each = {
    for dvo in aws_acm_certificate.ipfs-admin.domain_validation_options : dvo.domain_name => {
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

# resource "aws_route53_record" "validation_chainlink" { 
#   for_each = {
#     for dvo in aws_acm_certificate.chainlink.domain_validation_options : dvo.domain_name => {
#       name   = dvo.resource_record_name
#       record = dvo.resource_record_value
#       type   = dvo.resource_record_type
#     }
#   }

#   allow_overwrite = true

#   zone_id   = data.aws_route53_zone.frenchbtc-fr.zone_id
#   name      = each.value.name
#   type      = each.value.type
#   records   = [ each.value.record ]
#   ttl       = 10
# }

resource "aws_route53_record" "frontend" {
  zone_id = data.aws_route53_zone.frenchbtc-fr.zone_id
  name    = var.lb_dns_record_frontend
  type    = "CNAME"
  ttl     = "10"
  records = [ aws_lb.frontend.dns_name ]
}

output "aws_route53_record-frontend" {
  value = var.lb_dns_record_frontend
}

resource "aws_route53_record" "ipfs" {
  zone_id = data.aws_route53_zone.frenchbtc-fr.zone_id
  name    = var.lb_dns_record_ipfs
  type    = "CNAME"
  ttl     = "10"
  records = [ aws_lb.ipfs.dns_name ]
}

output "aws_route53_record-ipfs" {
  value = var.lb_dns_record_ipfs
}

resource "aws_route53_record" "ipfs-admin" {
  zone_id = data.aws_route53_zone.frenchbtc-fr.zone_id
  name    = var.lb_dns_record_ipfs_admin
  type    = "CNAME"
  ttl     = "10"
  records = [ aws_lb.ipfs-admin.dns_name ]
}

output "aws_route53_record-ipfs-admin" {
  value = var.lb_dns_record_ipfs_admin
}

# resource "aws_route53_record" "chainlink" {
#   zone_id = data.aws_route53_zone.frenchbtc-fr.zone_id
#   name    = var.lb_dns_record_chainlink
#   type    = "CNAME"
#   ttl     = "10"
#   records = [ aws_lb.chainlink.dns_name ]
# }

# output "aws_route53_record-chainlink" {
#   value = var.lb_dns_record_ipfs_admin
# }