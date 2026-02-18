# Project Context

Cookiecutter template (Jinja2 syntax). Files cannot be run directly — render first with `cruft create`.

## Do not modify

Hidden folders (`.elasticbeanstalk`, `.github`, `.platform`), `docker-compose.yml`, `cookiecutter.json`, `scripts/`, `proxy/`.

## Running locally

Render, then run from the output directory:

```bash
cruft create /path/to/this-repo --output-dir /tmp/out --no-input
cd /tmp/out/quick-app
```

Create `.env`:
```
AUTH_URL=http://localhost
AUTH_SECRET=dev-secret-key
ALLOWED_DOMAIN=example.com
DEV_AUTH=true
BACKEND_URL=http://backend:8000
```

```bash
docker compose build && docker compose up -d
```

Open http://localhost. `DEV_AUTH=true` bypasses Google OAuth with a fake user.
