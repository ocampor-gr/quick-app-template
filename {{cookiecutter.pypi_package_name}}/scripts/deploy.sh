#!/bin/bash
#
# Deploy the application to Elastic Beanstalk via Terraform.
#
# Flow:
#   1. Package the source tree as a versioned zip (image is built on EB).
#   2. Upload the zip to the Terraform state bucket.
#   3. Apply Terraform to register the new application version and tell EB
#      to roll the environment forward.
#   4. Verify EB is actually running the new version (guards against silent
#      rollbacks where Terraform succeeds but EB rejects the deploy).
#
set -euo pipefail

# ---------- config ----------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
INFRA_DIR="${PROJECT_DIR}/infra/app"

source "${SCRIPT_DIR}/utils.sh"
require_commands zip aws terraform git

APP_NAME="{{ cookiecutter.eb_app_name }}"
BUCKET="${TF_STATE_BUCKET:?TF_STATE_BUCKET is required}"
REGION="${TF_STATE_REGION:?TF_STATE_REGION is required}"

TIMESTAMP=$(date +%Y%m%d%H%M%S)
SHORT_SHA=$(git -C "${PROJECT_DIR}" rev-parse --short HEAD 2>/dev/null || echo "local")
VERSION_LABEL="${APP_NAME}-${TIMESTAMP}-${SHORT_SHA}"
ZIP_FILE="/tmp/${VERSION_LABEL}.zip"
S3_KEY="${APP_NAME}/versions/${VERSION_LABEL}.zip"

trap 'rm -f "${ZIP_FILE}"' EXIT

# ---------- helpers ---------------------------------------------------------

fail() { echo "" >&2; echo "ERROR: $*" >&2; }

deployed_version_label() {
  aws elasticbeanstalk describe-environments \
    --environment-names "${APP_NAME}" \
    --region "${REGION}" \
    --query 'Environments[0].VersionLabel' \
    --output text
}

dump_recent_eb_events() {
  aws elasticbeanstalk describe-events \
    --environment-name "${APP_NAME}" \
    --region "${REGION}" \
    --max-records 15 \
    --query 'Events[*].[EventDate,Severity,Message]' \
    --output text >&2
}

# ---------- steps -----------------------------------------------------------

package_source() {
  info "Packaging application as ${VERSION_LABEL}"
  cd "${PROJECT_DIR}"
  zip -rq "${ZIP_FILE}" \
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
}

upload_bundle() {
  info "Uploading bundle to s3://${BUCKET}/${S3_KEY}"
  aws s3 cp "${ZIP_FILE}" "s3://${BUCKET}/${S3_KEY}"
}

apply_terraform() {
  info "Applying Terraform (version: ${VERSION_LABEL})"
  cd "${INFRA_DIR}"
  terraform init -input=false \
      -backend-config="bucket=${BUCKET}" \
      -backend-config="region=${REGION}" \
      -backend-config="key=${APP_NAME}/terraform.tfstate"
  terraform apply -input=false -auto-approve \
      -var="eb_app_name=${APP_NAME}" \
      -var="app_version_label=${VERSION_LABEL}" \
      -var="tf_state_bucket=${BUCKET}"
}

verify_deployment() {
  info "Verifying environment is running ${VERSION_LABEL}"
  local running
  running=$(deployed_version_label)
  if [ "${running}" != "${VERSION_LABEL}" ]; then
    fail "EB rolled back. Expected ${VERSION_LABEL}, running ${running}."
    echo "Recent EB events:" >&2
    dump_recent_eb_events
    exit 1
  fi
}

# ---------- main ------------------------------------------------------------

package_source
upload_bundle
apply_terraform
verify_deployment

success "Deployment complete: ${VERSION_LABEL}"
