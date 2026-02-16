import logging

from authlib.integrations.starlette_client import OAuthError
from fastapi import APIRouter
from starlette.requests import Request
from starlette.responses import HTMLResponse, RedirectResponse

from app.config import oauth

router = APIRouter()


@router.get("/login")
async def login(request: Request):
	redirect_uri = request.url_for("auth")
	return await oauth.google.authorize_redirect(request, redirect_uri=redirect_uri)


@router.get("/auth")
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


@router.get("/logout")
async def logout(request: Request):
	request.session.clear()
	return RedirectResponse(url="/")


@router.get("/user-status")
async def get_user_status(request: Request):
	user = request.session.get("user")
	return {"authenticated": user is not None, "user": user}
