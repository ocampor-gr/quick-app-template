import os

from fastapi import FastAPI
from starlette.middleware.cors import CORSMiddleware
from starlette.middleware.sessions import SessionMiddleware
from starlette.requests import Request
from starlette.responses import RedirectResponse

from app.auth import COOKIE_NAME, create_token
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

if os.environ.get("DEV_AUTH", "").lower() == "true":

    @app.middleware("http")
    async def dev_auth_middleware(request: Request, call_next):  # type: ignore[no-untyped-def]
        if not request.cookies.get(COOKIE_NAME):
            token = create_token(
                {
                    "sub": "dev",
                    "name": "Dev User",
                    "email": "dev@example.com",
                    "picture": "",
                }
            )
            redirect_url = os.environ.get("AUTH_URL", str(request.url))
            response = RedirectResponse(redirect_url)
            response.set_cookie(
                key=COOKIE_NAME,
                value=token,
                httponly=True,
                samesite="lax",
                secure=False,
                path="/",
            )
            return response
        return await call_next(request)


app.include_router(auth.router)
app.include_router(hello.router)
{% if cookiecutter.include_database == "yes" %}
app.include_router(health.router)
{% endif %}
