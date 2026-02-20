# Infra cleanup: terraform_data, AL2023, stale descriptions

## Context
Three cleanup issues found during infra review: deprecated `null_resource`, EOL solution stack, and stale variable descriptions left over from previous refactoring.

## Changes

### 1. `main.tf` — Replace `null_resource` with `terraform_data`
- Change `resource "null_resource" "_"` → `resource "terraform_data" "_"`
- Replace `triggers` with `triggers_replace` (terraform_data API)
- Keep the `provisioner "local-exec"` block as-is

### 2. `variables.tf` — Update solution stack and descriptions
- `solution_stack_name` default: `"64bit Amazon Linux 2 running Docker"` → `"64bit Amazon Linux 2023 running Docker"`
- `app_subnet_ids` description: remove "and DB subnet group"
- `security_group_id` description: change "for instances and RDS" → "for EB instances"

### 3. `providers.tf` — Remove null provider dependency
- No changes needed — `hashicorp/null` was never declared in `required_providers`, it was auto-resolved. With `terraform_data` it won't be pulled in at all.

## Verification
```bash
git clean -fdX {{cookiecutter.pypi_package_name}}/
rm -rf /tmp/out /tmp/out-db
cookiecutter . --output-dir /tmp/out --no-input
cookiecutter . --output-dir /tmp/out-db --no-input include_database=yes
cd /tmp/out/quick-app/infra && terraform init -backend=false && terraform validate
cd /tmp/out-db/quick-app/infra && terraform init -backend=false && terraform validate
```
