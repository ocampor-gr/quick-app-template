# Phase 2: Deployment Script

Replace `eb` CLI in deploy scripts with `aws` CLI.

## 2.1 Rewrite `scripts/deploy.sh`

Replace `eb create`/`eb deploy` with:
1. `zip` the project (docker-compose.yml, backend/, frontend/, proxy/, .platform/) excluding node_modules/.venv/__pycache__/.next
2. `aws s3 cp` upload zip to the app-versions bucket
3. `aws elasticbeanstalk create-application-version`
4. `aws elasticbeanstalk update-environment` with new version
5. `aws elasticbeanstalk wait environment-updated`
6. Print environment URL

Version label: `{APP_NAME}-{timestamp}-{short SHA}`. No env var manipulation — secrets managed by Terraform.

## 2.2 Simplify `scripts/utils.sh`

Remove `create-env-list` function (no longer needed). Keep `print-env-url`.

## 2.3 Update `scripts/setup-infra.sh`

Change to plan-then-apply: `terraform plan -out=tfplan` then print instructions to apply.

## Verification

```bash
# Syntax-check deploy script on rendered output
bash -n /tmp/out/quick-app/scripts/deploy.sh
```
