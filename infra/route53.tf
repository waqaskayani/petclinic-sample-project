resource "aws_route53_record" "domain_record" {
    zone_id = var.hosted_zone_id
    name    = "www.${var.domain_record}"
    type    = "A"

    alias {
        name                   = aws_route53_record.naked_domain_record.fqdn
        zone_id                = aws_route53_record.naked_domain_record.zone_id
        evaluate_target_health = true
    }
}

resource "aws_route53_record" "naked_domain_record" {
    zone_id = var.hosted_zone_id
    name    = var.domain_record
    type    = "A"

    alias {
        name                   = aws_lb.app_alb.dns_name
        zone_id                = aws_lb.app_alb.zone_id
        evaluate_target_health = true
    }
}
