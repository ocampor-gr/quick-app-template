source "./scripts/utils.sh"

ENV_NAME="{{cookiecutter.environment}}"
APPS=$(eb list)
ENV_VARS=$(create_env_list "GOOGLE_CLIENT_ID" "GOOGLE_CLIENT_SECRET")

if [ -z "${APPS}" ]; then
  eb create ${ENV_NAME} --envvars "${ENV_VARS}"
else
  eb deploy
fi
