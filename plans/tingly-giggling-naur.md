# Align .env.example and deploy.sh with docker-compose.yml + fix CNAME

## Context

`docker-compose.yml` is the ground truth for environment variables. Both `.env.example` and `deploy.sh` have drifted:

- **`NEXT_PUBLIC_BACKEND_URL` doesn't exist** — docker-compose and the frontend code use `BACKEND_URL`. The `NEXT_PUBLIC_` prefix is a stale leftover.
- **`.env.example` is missing `DEV_AUTH`** and has wrong `AUTH_URL` port (`3000` instead of `80` via nginx proxy).
- **`deploy.sh` hardcodes URLs** to a specific EB CNAME that won't work for fresh environments. The `print-env-url()` utility in `utils.sh` exists to solve this but is never called.
- **`deploy.sh` sets `NEXT_PUBLIC_BACKEND_URL`** which isn't a real env var. `BACKEND_URL` defaults to `http://backend:8000` in docker-compose, which works in EB too (inter-container), so it doesn't need to be set at deploy time.
- **`ALLOWED_DOMAIN`** is hardcoded to `graphitehq.com` in deploy.sh — should come from a GitHub secret.

## Changes

### 1. `.env.example` — align with docker-compose.yml

```
GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=
AUTH_SECRET=dev-secret-key
AUTH_URL=http://localhost
BACKEND_URL=http://backend:8000
ALLOWED_DOMAIN=example.com
DEV_AUTH=true
{% if cookiecutter.include_database %}
DB_PASS=pass
DB_USER=postgres
DB_PORT=5432
DB_NAME=postgres
DB_HOST=db
{% endif %}
```

Changes:
- `NEXT_PUBLIC_BACKEND_URL` → `BACKEND_URL` (matches docker-compose and frontend code)
- `AUTH_URL=http://localhost:3000` → `AUTH_URL=http://localhost` (port 80 via nginx proxy)
- Add `DEV_AUTH=true` (present in docker-compose, needed for local dev)
- Add `ALLOWED_DOMAIN=example.com`

### 2. `scripts/deploy.sh` — fix env vars and CNAME resolution

- Remove `NEXT_PUBLIC_BACKEND_URL` entirely (docker default `http://backend:8000` works in EB)
- Remove hardcoded EB URLs
- After `eb create`, resolve `AUTH_URL` from actual CNAME via `print-env-url()`
- Make `ALLOWED_DOMAIN` come from env (GitHub secret) instead of hardcoding

```bash
source "./scripts/utils.sh"

ENV_NAME="{{cookiecutter.eb_app_name}}"
APPS=$(eb list)

GOOGLE_CLIENT_ID=${GOOGLE_CLIENT_ID:-"client-id-is-missing"}
GOOGLE_CLIENT_SECRET=${GOOGLE_CLIENT_SECRET:-"client-secret-is-missing"}
AUTH_SECRET=$(openssl rand -base64 32)
ALLOWED_DOMAIN=${ALLOWED_DOMAIN:-"example.com"}
ENV_VARS=$(create-env-list "GOOGLE_CLIENT_ID" "GOOGLE_CLIENT_SECRET" "AUTH_SECRET" "ALLOWED_DOMAIN")

if [ -z "${APPS}" ]; then
  eb create ${ENV_NAME} \
      -i t3.large \
      --vpc.id vpc-0865d0fe1685e07c6 \
      --vpc.ec2subnets subnet-0f51fe4df99eafc89,subnet-09ed0579b716d86e3 \
      --vpc.elbsubnets subnet-0ffba3b26556c0a4d,subnet-0089669023c7960a1 \
      --vpc.securitygroups sg-01b0628a487f58d2b \
      --vpc.elbpublic \
      --envvars "${ENV_VARS}"

  CNAME=$(print-env-url "${ENV_NAME}")
  eb setenv AUTH_URL="http://${CNAME}"
else
  eb deploy
fi
```

### 3. `scripts/utils.sh` — fix `print-env-url` output format

Add `--output text` to the AWS CLI call so the CNAME is returned without JSON quotes. Also fix the query path (remove leading dot).

```bash
print-env-url() {
  local env_name=${1}
  local cname=$(aws elasticbeanstalk describe-environments \
    --environment-names "${env_name}" \
    --query 'Environments[0].CNAME' \
    --output text)

  echo "${cname:-localhost}"
}
```

### 4. `.github/workflows/deploy.yml` — add `ALLOWED_DOMAIN` secret

Pass `ALLOWED_DOMAIN` from GitHub secrets to the deploy script:

```yaml
    - name: Deploy to Elastic Beanstalk
      env:
        {% raw %}
        GOOGLE_CLIENT_ID: ${{ secrets.GOOGLE_CLIENT_ID }}
        GOOGLE_CLIENT_SECRET: ${{ secrets.GOOGLE_CLIENT_SECRET }}
        ALLOWED_DOMAIN: ${{ secrets.ALLOWED_DOMAIN }}
        {% endraw %}
      run: bash ./scripts/deploy.sh
```

## Files to modify

- `{{cookiecutter.pypi_package_name}}/.env.example`
- `{{cookiecutter.pypi_package_name}}/scripts/deploy.sh`
- `{{cookiecutter.pypi_package_name}}/scripts/utils.sh`
- `{{cookiecutter.pypi_package_name}}/.github/workflows/deploy.yml`

## Verification

1. Render the template: `cruft create /path/to/repo --output-dir /tmp/out --no-input`
2. Confirm `.env.example` vars match `docker-compose.yml` services
3. Confirm `deploy.sh` no longer references `NEXT_PUBLIC_BACKEND_URL`
4. Confirm `deploy.sh` resolves `AUTH_URL` from CNAME after `eb create`
5. Confirm `deploy.yml` passes `ALLOWED_DOMAIN` as an env var
