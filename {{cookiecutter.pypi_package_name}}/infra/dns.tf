{% if cookiecutter.include_custom_domain == "yes" %}
{% raw %}
variable "hosted_zone_id" {
  description = "Existing Route 53 hosted zone ID. Leave empty to create a new one."
  type        = string
  default     = ""
}

variable "certificate_arn" {
  description = "Existing ACM certificate ARN. Leave empty to create a new one."
  type        = string
  default     = ""
}

locals {
  create_zone = var.hosted_zone_id == ""
  create_cert = var.certificate_arn == ""
  zone_id     = local.create_zone ? aws_route53_zone._[0].zone_id : var.hosted_zone_id
  cert_arn    = local.create_cert ? aws_acm_certificate_validation._[0].certificate_arn : var.certificate_arn
}

# --- Self-contained resources (created only when IDs not provided) ---

resource "aws_route53_zone" "_" {
  count = local.create_zone ? 1 : 0
  name  = var.domain_name
}

resource "aws_acm_certificate" "_" {
  count             = local.create_cert ? 1 : 0
  domain_name       = var.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_validation" {
  for_each = local.create_cert ? {
    for dvo in aws_acm_certificate._[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  } : {}

  zone_id         = local.zone_id
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
}

resource "aws_acm_certificate_validation" "_" {
  count                   = local.create_cert ? 1 : 0
  certificate_arn         = aws_acm_certificate._[0].arn
  validation_record_fqdns = [for r in aws_route53_record.cert_validation : r.fqdn]
}

# --- Always created: CNAME record pointing domain to EB ---

resource "aws_route53_record" "app" {
  zone_id = local.zone_id
  name    = var.domain_name
  type    = "CNAME"
  ttl     = 300
  records = [aws_elastic_beanstalk_environment._.cname]
}
{% endraw %}
{% endif %}
