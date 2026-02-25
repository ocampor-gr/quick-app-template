from starlette.testclient import TestClient
{%- if cookiecutter.include_database == "yes" %}
from collections.abc import Generator
from unittest.mock import MagicMock

import pytest

from app.models import Note
{%- endif %}


def test_health_check(client: TestClient) -> None:
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}
{%- if cookiecutter.include_database == "yes" %}


@pytest.fixture()
def mock_session(client: TestClient) -> Generator[MagicMock, None, None]:
    """Override the get_session dependency with a mock."""
    from app.database import get_session

    mock = MagicMock()
    client.app.dependency_overrides[get_session] = lambda: mock  # type: ignore[attr-defined]
    yield mock
    client.app.dependency_overrides.clear()  # type: ignore[attr-defined]


def test_ping_db_with_note(client: TestClient, mock_session: MagicMock) -> None:
    mock_note = Note(id=1, content="Hello from Alembic!")
    mock_session.exec.return_value.first.return_value = mock_note

    response = client.get("/ping-db")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "ok"
    assert data["message"] == "Hello from Alembic!"


def test_ping_db_no_notes(client: TestClient, mock_session: MagicMock) -> None:
    mock_session.exec.return_value.first.return_value = None

    response = client.get("/ping-db")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "ok"
    assert data["message"] == "Database connected but no notes found"


def test_ping_db_connection_failure(client: TestClient, mock_session: MagicMock) -> None:
    from sqlalchemy.exc import SQLAlchemyError

    mock_session.exec.side_effect = SQLAlchemyError("Connection refused")

    response = client.get("/ping-db")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "error"
    assert data["message"] == "Database connection failed"
{%- endif %}
