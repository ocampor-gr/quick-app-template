from datetime import datetime, timezone

from sqlmodel import Field, SQLModel


class Note(SQLModel, table=True):
    """A simple note for demonstrating database migrations."""

    id: int | None = Field(default=None, primary_key=True)
    content: str = Field(max_length=500)
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
