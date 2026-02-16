import os
import shutil

REMOVE_PATHS = [
	'{% if cookiecutter.include_database != "yes" %}backend/app/database.py{% endif %}',
	'{% if cookiecutter.include_database != "yes" %}backend/app/routes/health.py{% endif %}',
]

for path in REMOVE_PATHS:
	path = path.strip()
	if path and os.path.exists(path):
		if os.path.isfile(path):
			os.unlink(path)
		elif os.path.isdir(path):
			shutil.rmtree(path)
