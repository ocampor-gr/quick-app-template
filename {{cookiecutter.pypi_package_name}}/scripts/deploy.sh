#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
INFRA_DIR="${PROJECT_DIR}/infra"

APP_NAME="{{ cookiecutter.eb_app_name }}"
BUCKET="${TF_STATE_BUCKET:?TF_STATE_BUCKET is required}"
REGION="${TF_STATE_REGION:?TF_STATE_REGION is required}"
TIMESTAMP=$(date +%Y%m%d%H%M%S)
SHORT_SHA=$(git -C "${PROJECT_DIR}" rev-parse --short HEAD 2>/dev/null || echo "local")
VERSION_LABEL="${APP_NAME}-${TIMESTAMP}-${SHORT_SHA}"
ZIP_FILE="/tmp/${VERSION_LABEL}.zip"
S3_KEY="${APP_NAME}/versions/${VERSION_LABEL}.zip"

echo "==> Packaging application as ${VERSION_LABEL}"
cd "${PROJECT_DIR}"
zip -r "${ZIP_FILE}" \
    docker-compose.yml \
    backend/ \
    frontend/ \
    proxy/ \
    .platform/ \
    -x "*/node_modules/*" \
    -x "*/.venv/*" \
    -x "*/__pycache__/*" \
    -x "*/.next/*" \
    -x "*/.git/*"

echo "==> Uploading to s3://${BUCKET}/${S3_KEY}"
aws s3 cp "${ZIP_FILE}" "s3://${BUCKET}/${S3_KEY}"
rm -f "${ZIP_FILE}"

echo "==> Deploying via Terraform (version: ${VERSION_LABEL})"
cd "${INFRA_DIR}"
terraform init -input=false \
    -backend-config="bucket=${BUCKET}" \
    -backend-config="region=${REGION}" \
    -backend-config="key=${APP_NAME}/terraform.tfstate"
terraform apply -input=false -auto-approve \
    -var="eb_app_name=${APP_NAME}" \
    -var="app_version_label=${VERSION_LABEL}" \
    -var="tf_state_bucket=${BUCKET}"

echo "==> Deployment complete: ${VERSION_LABEL}"
