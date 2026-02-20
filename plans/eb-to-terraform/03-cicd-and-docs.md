# Phase 3: CI/CD & Docs

Update GitHub Actions workflow and documentation.

## 3.1 Simplify `.github/workflows/deploy.yml`

- Remove `pip install awscli awsebcli` (aws CLI pre-installed on ubuntu-latest)
- Remove `GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET`, `ALLOWED_DOMAIN` env vars (managed by Terraform, not passed at deploy time)
- Pass `GITHUB_SHA` and `AWS_REGION` to `deploy.sh`

## 3.2 Update `README.md`

Rewrite "Deploy Manually" section:
- Replace `eb init`/`eb create`/`eb deploy`/`eb terminate` with Terraform + aws CLI commands
- `cd infra && terraform init && terraform apply` for provisioning
- `bash scripts/deploy.sh` for deployment
- `cd infra && terraform destroy` for cleanup
