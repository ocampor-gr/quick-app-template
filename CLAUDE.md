# Project Context

Cookiecutter template (Jinja2 syntax). Files cannot be run directly — render first with `cruft create`.

## Do not modify

Hidden folders (`.elasticbeanstalk`, `.github`, `.platform`), `docker-compose.yml`, `cookiecutter.json`, `scripts/`, `proxy/`.

## Render & run

```bash
cruft create /path/to/this-repo --output-dir /tmp/out --no-input
cd /tmp/out/quick-app
docker compose build && docker compose up -d   # http://localhost
```

`DEV_AUTH=true` in `.env` bypasses Google OAuth with a fake user.

## Test uncommitted changes

`cruft create` only sees committed files. Use `cookiecutter` against the working tree instead:

```bash
git clean -fdX {{cookiecutter.pypi_package_name}}/
cookiecutter . --output-dir /tmp/out --no-input                          # without DB
cookiecutter . --output-dir /tmp/out-db --no-input include_database=yes  # with DB
```

If `cookiecutter` is not on PATH: `/home/ocampor/.local/share/pipx/venvs/cruft/bin/cookiecutter`

After rendering, run tests and lint from the output directory:

```bash
cd /tmp/out/quick-app

# Backend
cd backend
uv sync
uv run ruff check --fix
uv run ruff format --check
uv run mypy .
uv run pytest -n auto --timeout=30 -v

# Frontend
cd ../frontend
bun install
bun run lint
```

## Rules

1. When executing bash commands, you must not use 2>&1 redirection. All commands should be run without this specific redirection
