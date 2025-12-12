## Local Development

1. Install uv

```
pip install uv
```

2. Install libraries.

```bash
uv install
```

3. Start local server.

```bash
set -a && source .env && set +a
uvicorn main:app --reload --port=8000
```
