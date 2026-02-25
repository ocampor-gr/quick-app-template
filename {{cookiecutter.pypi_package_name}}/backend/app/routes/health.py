from fastapi import APIRouter
{%- if cookiecutter.include_database == "yes" %}
import logging

from sqlalchemy import select, text
from sqlalchemy.exc import SQLAlchemyError

from app.database import SessionDep
{%- endif %}

router = APIRouter()


@router.get("/health")
async def health_check() -> dict[str, str]:
    return {"status": "ok"}
{%- if cookiecutter.include_database == "yes" %}


@router.get("/ping-db")
async def ping_database(session: SessionDep):
    try:
        session.exec(select(text("1")))
        return {"status": "ok", "message": "Database connection successful"}
    except SQLAlchemyError as e:
        logging.error(f"Database connection failed: {str(e)}")
        return {"status": "error", "message": "Database connection failed"}
{%- endif %}
