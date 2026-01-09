import os

REMOVE_PATHS = [
	'{% if cookiecutter.include_database != "yes" %}database.py{% endif %}',
]

for path in REMOVE_PATHS:
	path = path.strip()
	if path and os.path.exists(path):
		os.unlink(path) if os.path.isfile(path) else os.rmdir(path)
