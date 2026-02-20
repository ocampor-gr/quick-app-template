#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")/../infra"
terraform init
terraform apply
