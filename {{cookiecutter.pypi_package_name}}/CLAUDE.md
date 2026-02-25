# Project Context

## Do not modify

Hidden folders (`.elasticbeanstalk`, `.github`, `.platform`), `docker-compose.yml`, `scripts/`, `proxy/`.

## Architecture

`frontend/CLAUDE.md` for frontend-specific guidelines
- `backend/` - FastAPI (Python 3.13+, uv) — see `backend/CLAUDE.md` for backend-specific guidelines
- `proxy/` - Nginx: `/api/v1/*` -> backend, everything else -> frontend

**Important**: Before working on code in `frontend/` or `backend/`, always read and follow the corresponding `CLAUDE.md` in that directory.

## Running locally

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

## Rules

1. When executing bash commands, you must not use 2>&1 redirection. All commands should be run without this specific redirection
