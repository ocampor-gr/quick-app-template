source "./scripts/utils.sh"

ENV_NAME="{{cookiecutter.environment}}"
APPS=$(eb list)

GOOGLE_CLIENT_ID=${GOOGLE_CLIENT_ID:-"client-id-is-missing"}
GOOGLE_CLIENT_SECRET=${GOOGLE_CLIENT_SECRET:-"client-secret-is-missing"}
AUTH_SECRET=$(openssl rand -base64 32)
AUTH_URL=$(print-env-url ${ENV_NAME})

ENV_VARS=$(create-env-list "GOOGLE_CLIENT_ID" "GOOGLE_CLIENT_SECRET" "AUTH_SECRET" "AUTH_URL")

if [ -z "${APPS}" ]; then
  eb create ${ENV_NAME} --envvars "${ENV_VARS}"
else
  eb deploy
fi
