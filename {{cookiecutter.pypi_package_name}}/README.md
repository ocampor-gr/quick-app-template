# {{ cookiecutter.pypi_package_name }}

{{ cookiecutter.project_short_description }}

{% if cookiecutter.include_database == "yes" %}
## Local Database

Requires [Docker](https://www.docker.com/get-started/).

1. Create or update `.env` with the DB fields.
2. Start the database and run migrations:
   ```bash
   docker compose up db -d
   cd backend && uv run alembic upgrade head
   ```
3. Verify: `curl http://localhost:8000/ping-db`

> **Tip:** If you change the password, delete the Docker DB volume with `docker volume prune`.

See `backend/README.md` for migration workflow (create, rollback, autogenerate).
{% endif %}

## Deployment

Infrastructure is managed with [Terraform](https://developer.hashicorp.com/terraform/install) (>= 1.10).

### Prerequisites

1. Install [Terraform](https://developer.hashicorp.com/terraform/install) (>= 1.10) and [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html).
2. Create a shared S3 bucket for Terraform state:
   ```bash
   aws s3api create-bucket \
     --bucket <your-terraform-state-bucket> \
     --region us-east-2 \
     --create-bucket-configuration LocationConstraint=us-east-2
   ```
3. Copy `infra/terraform.tfvars.example` to `infra/terraform.tfvars` and fill in your values.
4. Export the required environment variables:
   ```bash
   export TF_STATE_BUCKET=<your-terraform-state-bucket>
   export TF_STATE_REGION=us-east-2
   ```

### Provision Infrastructure

```bash
cd infra
terraform init -input=false \
  -backend-config="bucket=$TF_STATE_BUCKET" \
  -backend-config="region=$TF_STATE_REGION"
terraform plan -out=tfplan
# Review the plan, then apply:
terraform apply tfplan
```

### Deploy Application

```bash
bash scripts/deploy.sh
```

This packages the app, uploads it to S3, and runs `terraform apply` to deploy.

### Cleanup

```bash
cd infra
terraform destroy
```

### GitHub Actions Secrets

The CI/CD pipeline (`.github/workflows/deploy.yml`) requires these secrets:

| Secret | Description |
|--------|-------------|
| `AWS_ACCESS_KEY_ID` | AWS access key |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key |
| `AWS_REGION` | AWS region (e.g. `us-east-2`) |
| `TF_STATE_BUCKET` | S3 bucket for Terraform state |
| `TF_STATE_REGION` | Region of the state bucket |
| `VPC_ID` | VPC ID for the EB environment |
| `APP_SUBNET_IDS` | JSON list of app subnet IDs (e.g. `["subnet-xxx","subnet-yyy"]`) |
| `ELB_SUBNET_IDS` | JSON list of ELB subnet IDs (e.g. `["subnet-xxx","subnet-yyy"]`) |
| `SECURITY_GROUP_ID` | Security group ID for EB instances |
| `GOOGLE_CLIENT_ID` | Google OAuth client ID |
| `GOOGLE_CLIENT_SECRET` | Google OAuth client secret |
| `AUTH_SECRET` | Auth secret key (`openssl rand -base64 32`) |
{%- if cookiecutter.include_custom_domain == "yes" %}
| `DOMAIN_NAME` | Root domain name (e.g. `{{ cookiecutter.domain_name }}`) |
| `SUBDOMAIN` | Subdomain prefix (e.g. `app` for `app.{{ cookiecutter.domain_name }}`; empty for bare domain) |
| `HOSTED_ZONE_ID` | Route 53 hosted zone ID (empty to create new) |
| `CERTIFICATE_ARN` | ACM certificate ARN (empty to create new) |
{%- endif %}
{%- if cookiecutter.include_database == "yes" %}
| `DB_PASSWORD` | RDS master password |
{%- endif %}

## Generate AUTH_SECRET

```bash
openssl rand -base64 32
```

{% if cookiecutter.include_custom_domain == "yes" %}
## Custom Domain Setup

{% if cookiecutter.subdomain -%}
This project is configured with HTTPS for `{{ cookiecutter.subdomain }}.{{ cookiecutter.domain_name }}`.
{%- else -%}
This project is configured with HTTPS for `{{ cookiecutter.domain_name }}`.
{%- endif %}

### Option A: Shared Infrastructure

If you already have a Route 53 hosted zone and ACM certificate (e.g., a wildcard cert for `*.{{ cookiecutter.domain_name }}`):

1. Set `hosted_zone_id` and `certificate_arn` in `infra/terraform.tfvars` (or as GitHub Secrets).
2. Deploy — Terraform will create a CNAME record and configure the HTTPS listener.

To find existing hosted zones and certificates, run:

```bash
# List hosted zones
aws route53 list-hosted-zones --query 'HostedZones[].{Id:Id,Name:Name}' --output table

# List ACM certificates (use your EB region)
aws acm list-certificates --query 'CertificateSummaryList[].{ARN:CertificateArn,Domain:DomainName}' --output table --region <your-region>

# Verify a certificate covers your domain (wildcard *.domain or exact match)
aws acm describe-certificate --certificate-arn "<arn>" --query 'Certificate.{Domain:DomainName,SANs:SubjectAlternativeNames}' --region <your-region>
```

Use the zone ID (without the `/hostedzone/` prefix) and the certificate ARN that matches `*.{{ cookiecutter.domain_name }}`.

### Option B: Self-Contained

Leave `hosted_zone_id` and `certificate_arn` empty. Terraform will create a new Route 53 zone for `{{ cookiecutter.domain_name }}` and an ACM certificate.

{% if cookiecutter.subdomain -%}
The subdomain `{{ cookiecutter.subdomain }}` is automatically prepended — the full domain will be `{{ cookiecutter.subdomain }}.{{ cookiecutter.domain_name }}`.
{%- endif %}

1. Run `terraform apply` to create the infrastructure.
2. Get the nameservers: `cd infra && terraform output nameservers`
3. Update your domain registrar to use these nameservers.
4. Wait for DNS propagation (typically minutes, up to 48 hours). The ACM certificate validates automatically once DNS propagates.
{% endif %}

## Google Auth Credentials

Add the production URL to authorized redirect URIs in [Google Console](https://console.cloud.google.com/apis/credentials):

{% if cookiecutter.include_custom_domain == "yes" %}
```
https://{% if cookiecutter.subdomain %}{{ cookiecutter.subdomain }}.{% endif %}{{ cookiecutter.domain_name }}/api/v1/auth/callback
```
{% else %}
```
http://<your-eb-cname>/api/v1/auth/callback
```

You can find your EB CNAME with:

```bash
cd infra && terraform output eb_environment_cname
```
{% endif %}
