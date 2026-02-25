# {{ cookiecutter.pypi_package_name }}

{{ cookiecutter.project_short_description }}

{% if cookiecutter.include_database == "yes" %}
## Local Database

Requires [Docker](https://www.docker.com/get-started/).

1. Create or update `.env` with the DB fields.
2. Start the database:
   ```bash
   docker compose up db
   ```
3. Test the connection (requires `psql`):
   ```bash
   psql -h 0.0.0.0 -p 5432 -U postgres
   ```

> **Tip:** If you change the password, delete the Docker DB volume with `docker volume prune`.
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
{%- if cookiecutter.include_database == "yes" %}
| `DB_PASSWORD` | RDS master password |
{%- endif %}

## Generate AUTH_SECRET

```bash
openssl rand -base64 32
```

## Google Auth Credentials

Add the production URL to authorized redirect URIs in [Google Console](https://console.cloud.google.com/apis/credentials):

```
http://<your-eb-cname>/api/auth/callback/google
```

You can find your EB CNAME with:

```bash
cd infra && terraform output eb_environment_cname
```
