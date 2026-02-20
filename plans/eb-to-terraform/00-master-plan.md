# Migrate Deployment from EB CLI to Terraform

## Context

The deployment currently uses `eb` CLI commands (via `scripts/deploy.sh`) to create and update Elastic Beanstalk environments. Infrastructure is partially managed — Terraform handles optional RDS but the EB environment itself is created imperatively with hardcoded VPC/subnet/SG IDs. This migration replaces the `eb` CLI with Terraform-managed EB resources and `aws` CLI for deployments.

**Approach**: Two-phase runtime workflow:
- **Provisioning** (manual, local state): `terraform apply` creates EB app, environment, IAM roles, S3 bucket, and optional RDS
- **Deployment** (CI/CD): `aws` CLI packages code → uploads to S3 → creates EB app version → updates environment

## Phases

| Phase | Focus | Files |
|-------|-------|-------|
| [Phase 1](01-terraform-infrastructure.md) | Terraform infrastructure | `infra/*.tf`, `.gitignore`, `.elasticbeanstalk/` (delete) |
| [Phase 2](02-deployment-script.md) | Deployment scripts | `scripts/deploy.sh`, `scripts/utils.sh`, `scripts/setup-infra.sh` |
| [Phase 3](03-cicd-and-docs.md) | CI/CD & docs | `.github/workflows/deploy.yml`, `README.md` |

## Files Unchanged

- `docker-compose.yml` — still used by EB Docker platform
- `proxy/` — nginx config still used in Docker
- `.platform/hooks/` — still needed for EB healthd
- `cookiecutter.json` — existing `eb_app_name`/`eb_environment` vars are reused in TF
- `providers.tf` — already correct, no backend needed (local state)
- `backend-ci.yml`, `security-scan.yml`, `claude.yml` — not affected
