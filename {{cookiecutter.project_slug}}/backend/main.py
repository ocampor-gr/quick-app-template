from fastapi import FastAPI
from starlette.middleware.cors import CORSMiddleware

app = FastAPI()

app.add_middleware(
	CORSMiddleware,
	allow_origins=["*"],  # TODO: Fix for prod
	allow_credentials=True,
	allow_methods=["*"],
	allow_headers=["*"],
)


@app.get("/")
async def root():
	return {"message": "Hello World"}


@app.get("/api/hello")
async def get_hello():
	return {
		"message": "Hello, world!!!",
		"method": "GET"
	}


@app.put("/api/hello")
async def put_hello():
	return {
		"message": "Hello, world!",
		"method": "PUT"
	}


@app.get("/api/hello/{name}")
async def get_hello_name(name: str):
	return {
		"message": f"Hello, {name}!"
	}
