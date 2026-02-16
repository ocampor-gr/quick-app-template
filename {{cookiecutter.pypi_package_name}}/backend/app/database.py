import os
from typing import Annotated

from fastapi import Depends
from sqlmodel import Session, create_engine

user = os.environ.get("DB_USER", "")
password = os.environ.get("DB_PASS", "")
port = os.environ.get("DB_PORT", "")
dbname = os.environ.get("DB_NAME", "")
host = os.environ.get("DB_HOST", "")

engine = create_engine(
	f"postgresql://{user}:{password}@{host}:{port}/{dbname}",
	pool_size=5,
	max_overflow=10
)


def get_session():
	with Session(engine) as session:
		yield session


SessionDep = Annotated[Session, Depends(get_session)]
