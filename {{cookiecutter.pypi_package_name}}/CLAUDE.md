# Project Context

## Do not modify

Hidden folders (`.elasticbeanstalk`, `.github`, `.platform`), `docker-compose.yml`, `scripts/`, `proxy/`.

## Architecture

- `frontend/` - Next.js 16 (Bun)
- `backend/` - FastAPI (Python 3.13+, uv)
- `proxy/` - Nginx: `/api/v1/*` -> backend, everything else -> frontend

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
