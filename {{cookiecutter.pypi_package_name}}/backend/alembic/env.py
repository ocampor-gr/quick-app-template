from alembic import context
from sqlmodel import SQLModel

from app import models  # noqa: F401
from app.database import engine

target_metadata = SQLModel.metadata


def run_migrations() -> None:
    with engine.connect() as connection:
        context.configure(
            connection=connection,
            target_metadata=target_metadata,
        )
        with context.begin_transaction():
            context.run_migrations()


run_migrations()
