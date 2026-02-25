from fastapi import APIRouter
{%- if cookiecutter.include_database == "yes" %}
import logging

from sqlalchemy.exc import SQLAlchemyError
from sqlmodel import select

from app.database import SessionDep
from app.models import Note
{%- endif %}

router = APIRouter()


@router.get("/health")
async def health_check() -> dict[str, str]:
    return {"status": "ok"}
{%- if cookiecutter.include_database == "yes" %}


@router.get("/ping-db")
async def ping_database(session: SessionDep):
    try:
        note = session.exec(select(Note).limit(1)).first()
        if note is None:
            return {"status": "ok", "message": "Database connected but no notes found"}
        return {"status": "ok", "message": note.content}
    except SQLAlchemyError as e:
        logging.error(f"Database connection failed: {str(e)}")
        return {"status": "error", "message": "Database connection failed"}
{%- endif %}
