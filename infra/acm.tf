resource "aws_acm_certificate" "app_cert" {
    domain_name                     = var.domain_record
    subject_alternative_names       = [ "www.${var.domain_record}" ]
    validation_method = "DNS"

    lifecycle {
        create_before_destroy = true
    }

    tags = merge(
        { 
            "Name" = "acm-cert-${var.environment}"
        },
        var.common_tags
    )
}

resource "aws_route53_record" "example" {
    for_each = {
        for dvo in aws_acm_certificate.app_cert.domain_validation_options : dvo.domain_name => {
        name   = dvo.resource_record_name
        record = dvo.resource_record_value
        type   = dvo.resource_record_type
        }
    }

    allow_overwrite = true
    name            = each.value.name
    records         = [each.value.record]
    ttl             = 60
    type            = each.value.type
    zone_id         = var.hosted_zone_id
}
