from starlette.testclient import TestClient


def test_user_status_unauthenticated(client: TestClient) -> None:
    response = client.get("/user-status")
    assert response.status_code == 200
    data = response.json()
    assert data["authenticated"] is False
    assert data["user"] is None


def test_logout_redirects(client: TestClient) -> None:
    response = client.get("/logout", follow_redirects=False)
    assert response.status_code == 307
    assert response.headers["location"] == "/"
