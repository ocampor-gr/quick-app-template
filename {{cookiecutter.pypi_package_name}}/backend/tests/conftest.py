import pytest
from starlette.testclient import TestClient


@pytest.fixture(autouse=True)
def _env_vars(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setenv("GOOGLE_CLIENT_ID", "test")
    monkeypatch.setenv("GOOGLE_CLIENT_SECRET", "test")
    monkeypatch.setenv("AUTH_URL", "http://localhost:3000")
    monkeypatch.setenv("AUTH_SECRET", "test-secret-key-for-jwt")
    monkeypatch.setenv("ALLOWED_DOMAIN", "graphitehq.com")
{%- if cookiecutter.include_database == "yes" %}
    monkeypatch.setenv("DB_USER", "test")
    monkeypatch.setenv("DB_PASS", "test")
    monkeypatch.setenv("DB_PORT", "5432")
    monkeypatch.setenv("DB_NAME", "test")
    monkeypatch.setenv("DB_HOST", "localhost")
{%- endif %}


@pytest.fixture()
def client() -> TestClient:
    from main import app

    return TestClient(app)
