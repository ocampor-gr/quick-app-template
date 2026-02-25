#!/bin/bash
set -ex

docker compose -f /var/app/staging/docker-compose.yml run --rm backend alembic upgrade head
