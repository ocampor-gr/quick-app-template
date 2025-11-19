import logging
import os
import secrets

from authlib.integrations.starlette_client import OAuth, OAuthError
from fastapi import FastAPI
from starlette.config import Config
from starlette.middleware.cors import CORSMiddleware
from starlette.middleware.sessions import SessionMiddleware
from starlette.requests import Request
from starlette.responses import HTMLResponse, RedirectResponse

app = FastAPI()

app.add_middleware(
	SessionMiddleware,
	secret_key=secrets.token_urlsafe(32),
	same_site="lax",
	https_only=False,  # TODO: This should be set to true in prod
)

config = Config(environ=dict(
	GOOGLE_CLIENT_ID=os.environ["GOOGLE_CLIENT_ID"],
	GOOGLE_CLIENT_SECRET=os.environ["GOOGLE_CLIENT_SECRET"],
))

oauth = OAuth(config=config)

oauth.register(
	name="google",
	server_metadata_url="https://accounts.google.com/.well-known/openid-configuration",
	client_kwargs={
		"scope": "openid email profile"
	}
)

app.add_middleware(
	CORSMiddleware,
	allow_origins=["*"],  # TODO: Fix for prod
	allow_credentials=True,
	allow_methods=["*"],
	allow_headers=["*"],
)


@app.get("/login")
async def login(request: Request):
	redirect_uri = request.url_for("auth")
	return await oauth.google.authorize_redirect(request, redirect_uri=redirect_uri)


@app.get("/auth")
async def auth(request: Request):
	try:
		token = await oauth.google.authorize_access_token(request)
		logging.info("OAuth token obtained successfully")
	except OAuthError as e:
		logging.error(f"OAuth error: {e.error} - {e.description}")
		return HTMLResponse(f"""
			<h1>OAuth Error: {e.error}</h1>
			<p>{e.description}</p>
		""")
	
	user = token.get("userinfo")
	
	if user:
		request.session["user"] = dict(user)
	return RedirectResponse("/")


@app.get('/logout')
async def logout(request: Request):
	request.session.clear()
	return RedirectResponse(url='/')


@app.get("/user-status")
async def get_user_status(request: Request):
	user = request.session.get("user")
	return {"authenticated": user is not None, "user": user}


@app.get("/hello")
async def get_hello():
	return {
		"message": "Hello, world!!!",
		"method": "GET"
	}


@app.put("/hello")
async def put_hello():
	return {
		"message": "Hello, world!",
		"method": "PUT"
	}


@app.get("/hello/{name}")
async def get_hello_name(name: str):
	return {
		"message": f"Hello, {name}!"
	}
