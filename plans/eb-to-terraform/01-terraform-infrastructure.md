# Phase 1: Terraform Infrastructure

Implement all Terraform resources to fully manage the EB environment.

## 1.1 Create `infra/rds.tf` — Extract from current `main.tf`

Move existing RDS + DB subnet group resources into a new file. Update `var.subnet_ids` → `var.app_subnet_ids`.

## 1.2 Rewrite `infra/variables.tf` — Make network vars unconditional, add EB vars

Move `vpc_id`, `subnet_ids`, `security_group_id` outside the `{% if include_database %}` conditional since EB always needs them. Rename `subnet_ids` → `app_subnet_ids`, add `elb_subnet_ids`. Add new variables:
- `instance_type` (default `t3.large`)
- `eb_app_name` (default from `cookiecutter.eb_app_name`)
- `eb_environment_name` (default from `cookiecutter.eb_environment`)
- `solution_stack_name` (default `64bit Amazon Linux 2 running Docker`)
- `google_client_id`, `google_client_secret`, `auth_secret` (sensitive)
- `allowed_domain` (default `graphitehq.com`)

Remove hardcoded defaults from network vars — users provide values via `terraform.tfvars`.

## 1.3 Rewrite `infra/main.tf` — EB resources

Replace RDS content (now in `rds.tf`) with:
- `aws_s3_bucket` + lifecycle config for app versions (expire after 30 days)
- `aws_iam_role` + `aws_iam_instance_profile` for EB EC2 instances (WebTier, MulticontainerDocker, WorkerTier, ECR policies)
- `aws_iam_role` for EB service role (EnhancedHealth, ManagedUpdates policies)
- `aws_elastic_beanstalk_application` with appversion lifecycle (keep 10)
- `aws_elastic_beanstalk_environment` with settings for:
  - VPC (vpc_id, subnets, elb_subnets, elb_scheme=public)
  - Instances (type, IAM profile, security groups)
  - Load balancer (type=application)
  - Env vars: `GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET`, `AUTH_SECRET`, `ALLOWED_DOMAIN`, `DEV_AUTH=false`
  - Conditional DB env vars (`DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASS`) referencing `aws_db_instance.main` when `include_database=yes`
- `null_resource` with `local-exec` to set `AUTH_URL` after environment creation (avoids circular dependency — env can't reference its own CNAME)

Jinja2/Terraform pattern: close `{% endraw %}` before `{% if %}` conditionals, reopen inside.

## 1.4 Update `infra/outputs.tf` — Add EB outputs

Add (unconditional): `eb_app_name`, `eb_environment_name`, `eb_environment_cname`, `eb_environment_url`, `s3_app_versions_bucket`. Keep existing conditional DB outputs.

## 1.5 Create `infra/terraform.tfvars.example`

Template with placeholder values for all required variables.

## 1.6 Update `.gitignore` — Add `terraform.tfvars` and `*.tfplan`

## 1.7 Delete `.elasticbeanstalk/` directory

No longer needed — EB configuration lives in Terraform.

## Verification

```bash
git clean -fdX {{cookiecutter.pypi_package_name}}/

# Render both variants
/home/ocampor/.local/share/pipx/venvs/cruft/bin/cookiecutter . --output-dir /tmp/out --no-input
/home/ocampor/.local/share/pipx/venvs/cruft/bin/cookiecutter . --output-dir /tmp/out-db --no-input include_database=yes

# Validate Terraform
cd /tmp/out/quick-app/infra && terraform init && terraform validate
cd /tmp/out-db/quick-app/infra && terraform init && terraform validate

# No Jinja2 artifacts in rendered output
grep -r '{%' /tmp/out/quick-app/infra/ || echo "Clean"
grep -r '{{' /tmp/out/quick-app/infra/ || echo "Clean"
```
