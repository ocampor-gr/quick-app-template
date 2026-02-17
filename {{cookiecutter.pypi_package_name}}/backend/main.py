import os

from fastapi import FastAPI
from starlette.middleware.cors import CORSMiddleware
from starlette.middleware.sessions import SessionMiddleware

from app.routes import auth, hello
{% if cookiecutter.include_database == "yes" %}
from app.routes import health
{% endif %}

app = FastAPI()

app.add_middleware(
	SessionMiddleware,
	secret_key=os.environ.get("AUTH_SECRET", "change-me-in-production"),
	same_site="lax",
	https_only=False,  # TODO: This should be set to true in prod
)

app.add_middleware(
	CORSMiddleware,
	allow_origins=["http://localhost:3000", os.environ.get("AUTH_URL", "")],
	allow_credentials=True,
	allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"],
	allow_headers=["Content-Type", "Authorization", "Accept"],
)

app.include_router(auth.router)
app.include_router(hello.router)
{% if cookiecutter.include_database == "yes" %}
app.include_router(health.router)
{% endif %}
