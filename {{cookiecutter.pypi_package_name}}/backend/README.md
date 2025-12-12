## Local Development

1. Install uv

```
pip install uv
```

2. Install libraries.

```bash
uv sync
```

3. Start local server.

```bash
set -a && source .env && set +a
uv run uvicorn main:app --reload --port=8000
```
