
# Backend Context

When working with this backend codebase, prioritize readability over cleverness. Ask clarifying questions before making architectural changes.

Do not modify any of the following files:
    - Any hidden folder or file. The hidden folders are the ones prefixed with a dot, for example 
        `.elasticbeanstalk`, `.github`, `.platform`.
    - Any infrastructure file like `docker-compose.yml`, `cookiecutter.json`, the files in the folder `scripts`, `Dockerfile` files,
        or the files in the folder `proxy`.

## About This Backend

FastAPI REST API for user authentication and profiles. Uses SQLAlchemy for database operations and Pydantic for validation.

## Key Files & Structure

- `main.py` - FastAPI application entry point
- `pyproject.toml` - Python project dependencies and configuration
- `Dockerfile` - Container configuration
- `app/` - Main application package (if exists)
- `tests/` - Test suite (if exists)

## Standards

- Type hints required on all functions
- PEP 8 with 100 character lines
- Use SQLAlchemy for database operations
- Use Pydantic for data validation

## Workflow
- Be sure to typecheck when you're done making a series of code changes
- Prefer running single tests, and not the whole test suite, for performance
- Use `uv` for dependency management
