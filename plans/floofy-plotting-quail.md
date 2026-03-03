# Plan: Add Production HTTPS & Custom Domain as Cookiecutter Option

## Context

The template currently deploys to AWS Elastic Beanstalk with HTTP only. The ALB has no HTTPS listener, `AUTH_URL` uses `http://`, and cookies are set with `secure=False`. Users who want a custom domain with HTTPS must manually configure ACM, Route 53, and ALB listener rules after rendering.

This plan adds an `include_custom_domain` cookiecutter option that, when enabled, provisions HTTPS via ALB and a Route 53 CNAME record. It supports two modes:

- **Shared infra**: User provides an existing `hosted_zone_id` and `certificate_arn` (e.g., a wildcard cert for `*.example.com`). The template only creates a CNAME record and HTTPS listener. Cost: **$0/month** extra.
- **Self-contained**: If those aren't provided, the template creates its own Route 53 zone and ACM certificate. Cost: **~$0.50/month** (hosted zone).

## Files to Modify

### 1. `cookiecutter.json` — add new variables

Add `include_custom_domain` and `domain_name` before the derived variables:

```json
"include_database": "no",
"include_custom_domain": "no",
"domain_name": "example.com",
"pypi_package_name": "..."
```

### 2. `hooks/post_gen_project.py` — clean up `dns.tf` when not needed

Add to `REMOVE_PATHS`:
```python
'{% if cookiecutter.include_custom_domain != "yes" %}infra/dns.tf{% endif %}',
```

### 3. NEW: `{{cookiecutter.pypi_package_name}}/infra/dns.tf` — Route 53 + ACM + CNAME

Wrapped in `{% if cookiecutter.include_custom_domain == "yes" %}`, following the `rds.tf` pattern.

**Shared vs self-contained logic using Terraform conditionals:**

```hcl
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
  lifecycle { create_before_destroy = true }
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
```

`local.cert_arn` is then referenced in `main.tf` for the HTTPS listener.

### 4. `{{cookiecutter.pypi_package_name}}/infra/main.tf` — HTTPS listener + AUTH_URL

**4a.** Add HTTPS listener settings inside `aws_elastic_beanstalk_environment` (after line 92, before the env vars block), wrapped in cookiecutter conditional:

```hcl
# Port 443 HTTPS listener
aws:elbv2:listener:443 → ListenerEnabled = true
aws:elbv2:listener:443 → Protocol = HTTPS
aws:elbv2:listener:443 → SSLCertificateArns = local.cert_arn
```

**4b.** Replace the `terraform_data._` resource (lines 170-183) with a conditional block:
- When custom domain enabled: `AUTH_URL=https://${var.domain_name}`, triggers on `domain_name`
- When disabled: keep current behavior (`AUTH_URL=http://${eb_cname}`)

### 5. `{{cookiecutter.pypi_package_name}}/infra/variables.tf` — add `domain_name`

After line 84, add conditional block (same pattern as DB vars):
```hcl
{% if cookiecutter.include_custom_domain == "yes" %}
variable "domain_name" {
  description = "Custom domain name for the application (e.g., app.example.com)"
  type        = string
  default     = "{{ cookiecutter.domain_name }}"
}
{% endif %}
```

Note: `hosted_zone_id` and `certificate_arn` variables live in `dns.tf` (step 3) to keep them co-located with the resources that use them.

### 6. `{{cookiecutter.pypi_package_name}}/infra/outputs.tf` — add DNS outputs

Between `{% endraw %}` (line 17) and the database conditional (line 18), add:
- `nameservers` — Route 53 NS records (only when zone is created, so user can update their registrar)
- `app_url` — `https://{{ cookiecutter.domain_name }}`

### 7. `{{cookiecutter.pypi_package_name}}/infra/terraform.tfvars.example`

Add conditional block at the end:
```hcl
{% if cookiecutter.include_custom_domain == "yes" %}
# domain_name    = "{{ cookiecutter.domain_name }}"
# hosted_zone_id = ""   # leave empty to create a new Route 53 zone
# certificate_arn = ""  # leave empty to create a new ACM certificate
{% endif %}
```

### 8. `{{cookiecutter.pypi_package_name}}/proxy/nginx.conf` — forward proto + HTTPS redirect

**8a. Unconditional fix** — add `X-Forwarded-Proto` header to both location blocks:
```nginx
proxy_set_header X-Forwarded-Proto $http_x_forwarded_proto;
```
This is a correctness fix: the backend's auth.py already reads this header but nginx never forwards it.

**8b. Conditional** — add HTTP→HTTPS redirect when custom domain is enabled:
```nginx
{% if cookiecutter.include_custom_domain == "yes" %}
if ($http_x_forwarded_proto = "http") {
    return 301 https://$host$request_uri;
}
{% endif %}
```

### 9. `{{cookiecutter.pypi_package_name}}/backend/main.py` — dynamic secure flags

Derive `https_only` and `secure` from `AUTH_URL` instead of hardcoded `False`:

- Line 21: `https_only=os.environ.get("AUTH_URL", "").startswith("https"),`
- Line 52: `secure=os.environ.get("AUTH_URL", "").startswith("https"),`

This works for all environments: local dev (`http://localhost` → False), production without domain (`http://cname` → False), production with domain (`https://domain` → True).

### 10. `{{cookiecutter.pypi_package_name}}/backend/app/routes/auth.py` — dynamic secure flag

- Add `import os` at the top
- Line 48: `secure=os.environ.get("AUTH_URL", "").startswith("https"),`

### 11. `{{cookiecutter.pypi_package_name}}/.github/workflows/deploy.yml` — new secrets

After line 45, add conditional variables (same pattern as `TF_VAR_db_password`):
- `TF_VAR_domain_name`
- `TF_VAR_hosted_zone_id`
- `TF_VAR_certificate_arn`

### 12. `{{cookiecutter.pypi_package_name}}/README.md` — documentation

- Add conditional "Custom Domain Setup" section after deployment docs explaining:
  - **Shared infra path**: provide `hosted_zone_id` and `certificate_arn` in tfvars
  - **Self-contained path**: leave them empty, deploy, then update registrar nameservers
- Add `DOMAIN_NAME`, `HOSTED_ZONE_ID`, `CERTIFICATE_ARN` to the GitHub Actions Secrets table
- Update the Google Auth Credentials section to show `https://{{ cookiecutter.domain_name }}` when custom domain is enabled

## Verification

```bash
# Render without custom domain
git clean -fdX {{cookiecutter.pypi_package_name}}/
/home/ocampor/.local/share/pipx/venvs/cruft/bin/cookiecutter . --output-dir /tmp/out --no-input

# Render with custom domain
/home/ocampor/.local/share/pipx/venvs/cruft/bin/cookiecutter . --output-dir /tmp/out-domain --no-input include_custom_domain=yes domain_name=app.example.com

# Verify dns.tf only exists in domain version
ls /tmp/out/quick-app/infra/dns.tf        # should NOT exist
ls /tmp/out-domain/quick-app/infra/dns.tf  # should exist

# Backend lint + tests for both renders
cd /tmp/out/quick-app/backend && uv sync && uv run ruff check --fix && uv run ruff format --check && uv run mypy . && uv run pytest -n auto --timeout=30 -v
cd /tmp/out-domain/quick-app/backend && uv sync && uv run ruff check --fix && uv run ruff format --check && uv run mypy . && uv run pytest -n auto --timeout=30 -v

# Verify nginx has X-Forwarded-Proto in both, redirect only in domain version
grep -c "X-Forwarded-Proto" /tmp/out/quick-app/proxy/nginx.conf       # should be 2
grep -c "301 https" /tmp/out/quick-app/proxy/nginx.conf                # should be 0
grep -c "301 https" /tmp/out-domain/quick-app/proxy/nginx.conf         # should be 1
```
