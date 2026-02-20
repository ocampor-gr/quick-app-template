# Phase 2: Migration from Elastic Beanstalk to App Runner

## Context

Replace Elastic Beanstalk deployment with **AWS App Runner**. This eliminates the nginx proxy (App Runner handles TLS), reduces idle cost from ~$100-120/mo to ~$22-36/mo, and simplifies the deploy pipeline to: push Docker images to ECR, trigger App Runner redeployment.

## Architecture

```
User → App Runner (frontend:3000) --Next.js rewrites /api/v1/*--> App Runner (backend:8000) --optional--> RDS
```

- Frontend App Runner = public entry point (HTTPS included)
- Backend App Runner = reached via Next.js rewrites (already in `next.config.ts`)
- Nginx proxy eliminated
- When `include_database` is enabled, backend reaches RDS via App Runner VPC connector

## Changes

### 1. Delete EB-specific files

| File | Reason |
|------|--------|
| `.elasticbeanstalk/config.yml` | EB CLI config |
| `.platform/` (entire directory) | EB platform hooks |
| `proxy/Dockerfile` | Nginx no longer needed |
| `proxy/nginx.conf` | Nginx no longer needed |

### 2. Modify `cookiecutter.json`

Remove `eb_app_name` and `eb_environment`. Add `aws_region`.

```json
{
  "github_username": "ocampor-gh",
  "github_branch": "master",
  "pypi_package_name": "quick-app",
  "include_database": "no",
  "project_slug": "{{ cookiecutter.pypi_package_name.replace('-', '_') }}",
  "aws_region": "us-east-2",
  "project_short_description": "Python Boilerplate contains all the boilerplate you need to create an App.",
  "__gh_slug": "{{ cookiecutter.github_username }}/{{ cookiecutter.project_slug }}"
}
```

### 3. Modify `docker-compose.yml`

Remove `nginx-proxy` service. Map frontend port `80:3000` so `http://localhost` works without nginx. Keep all database conditionals as-is. Add named volume for postgres data.

### 4. Add App Runner resources to `infra/main.tf`

Extend the Terraform from Phase 1 with:
- `aws_iam_role` + policy for App Runner ECR access
- `aws_apprunner_auto_scaling_configuration_version` (min 1, max 5)
- `aws_apprunner_service` x2 (frontend, backend) with ECR image source, env vars, health check
- Conditional: `aws_apprunner_vpc_connector` (when `include_database = true`, so backend can reach RDS)

### 5. Rewrite `scripts/deploy.sh`

Replace EB deploy with ECR push + App Runner deployment trigger:
- Login to ECR
- Build and push frontend + backend images
- Trigger `aws apprunner start-deployment` for both services

### 6. Delete `scripts/utils.sh`

EB-specific helpers (`create-env-list`, `print-env-url`) no longer needed.

### 7. Rewrite `.github/workflows/deploy.yml`

Replace EB CLI install + deploy with ECR login + deploy script. Keep same job structure (security-scan → backend-ci → deploy). Remove `pip install awscli awsebcli`.

### 8. Update inner `CLAUDE.md`

Update "Do not modify" list: remove `.elasticbeanstalk`, `.platform`, `proxy/`. Add `infra/`. Update "Running locally" to reflect no nginx.

## File summary

| Action | Path |
|--------|------|
| DELETE | `.elasticbeanstalk/config.yml` |
| DELETE | `.platform/` (entire directory) |
| DELETE | `proxy/Dockerfile` |
| DELETE | `proxy/nginx.conf` |
| DELETE | `scripts/utils.sh` |
| MODIFY | `cookiecutter.json` |
| MODIFY | `docker-compose.yml` |
| MODIFY | `infra/main.tf` (add App Runner resources) |
| MODIFY | `scripts/deploy.sh` (full rewrite) |
| MODIFY | `.github/workflows/deploy.yml` (full rewrite) |
| MODIFY | `CLAUDE.md` (inner template) |

**Unchanged**: `backend/`, `frontend/`, `.env.example`, `hooks/post_gen_project.py`, `backend-ci.yml`, `security-scan.yml`, `claude.yml`.

## Verification

1. Render template: `cruft create /path/to/this-repo --output-dir /tmp/out --no-input`
2. Local dev: `cd /tmp/out/quick-app && cp .env.example .env && docker compose build && docker compose up -d`
3. Check: `http://localhost` loads frontend, `http://localhost:8000/hello` returns JSON
4. Terraform validate: `cd /tmp/out/quick-app/infra && terraform init && terraform validate`
5. E2E tests: Run the `test-e2e` skill against the rendered template
