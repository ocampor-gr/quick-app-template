# Consolidate CI Workflows and Gate Deployments

## Context

Two problems with the current workflow setup:

1. **No backend CI before deploy** — `deploy.yml` only gates on a security scan before deploying to Elastic Beanstalk. Backend lint, typecheck, and tests only run on PRs (`backend-ci.yml`), so broken code could be deployed.
2. **Redundant security workflow files** — `security.yml` is a thin wrapper that just calls `security-scan.yml` on PRs. Now that we're giving workflows dual triggers (`pull_request` + `workflow_call`), the same consolidation should apply to security scanning.

## Approach

Give each CI workflow both a direct trigger (`pull_request`) and a reusable trigger (`workflow_call`), then call them from `deploy.yml`. Delete the redundant wrapper file.

## Changes

### 1. `backend-ci.yml` — add `workflow_call` trigger *(already done)*

```yaml
on:
  pull_request:
    paths:
      - "backend/**"
  workflow_call:
```

### 2. `security-scan.yml` — add `pull_request` and `workflow_dispatch` triggers, add `permissions`

Merge the `pull_request` trigger and `permissions` from `security.yml` into `security-scan.yml` so it serves both purposes. No `workflow_dispatch` — scan runs on PRs and deploys only.

```yaml
name: Security Scan

on:
  pull_request: {}
  workflow_call:

permissions:
  contents: read

jobs:
  security-scan:
    name: Run Security Scan
    runs-on: ubuntu-latest
    container:
      image: semgrep/semgrep
    steps:
      - uses: actions/checkout@v4
      - run: semgrep scan --error --config auto
```

### 3. Delete `security.yml`

No longer needed — `security-scan.yml` now handles PR triggers directly.

### 4. `deploy.yml` — add `backend-ci` job and update `needs` *(already done)*

```yaml
jobs:
  security-scan:
    name: Run Security Scan
    uses: ./.github/workflows/security-scan.yml
  backend-ci:
    name: Run Backend CI
    uses: ./.github/workflows/backend-ci.yml
  deploy:
    runs-on: ubuntu-latest
    needs: [security-scan, backend-ci]
    steps:
```

## Resulting Pipeline

```
pull request:
  +--> security-scan (semgrep, all PRs)
  +--> backend-ci (lint + typecheck + test, only backend/** changes)

push to main:
  +--> security-scan (semgrep)  --------+
  |                                      |
  +--> backend-ci                        |
  |      +--> lint (ruff)                |
  |      +--> typecheck (mypy)           +--> deploy (only if ALL pass)
  |      +--> test (pytest)              |
  |      (run in parallel)        ------+
```

## Files to Modify

- `{{cookiecutter.pypi_package_name}}/.github/workflows/backend-ci.yml` — add `workflow_call` trigger (already done)
- `{{cookiecutter.pypi_package_name}}/.github/workflows/security-scan.yml` — add `pull_request`, `workflow_dispatch` triggers and `permissions`
- `{{cookiecutter.pypi_package_name}}/.github/workflows/security.yml` — **delete**
- `{{cookiecutter.pypi_package_name}}/.github/workflows/deploy.yml` — add `backend-ci` job, update `needs` (already done)

## Verification

Render the template and inspect the generated workflows:
```bash
cruft create /path/to/this-repo --output-dir /tmp/out --no-input
cat /tmp/out/quick-app/.github/workflows/deploy.yml
cat /tmp/out/quick-app/.github/workflows/backend-ci.yml
cat /tmp/out/quick-app/.github/workflows/security-scan.yml
ls /tmp/out/quick-app/.github/workflows/  # confirm security.yml is gone
```
