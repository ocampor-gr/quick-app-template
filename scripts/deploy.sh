ENV_NAME=prod
APPS=$(eb list)

if [ -z "${APPS}" ]; then
  eb create ${ENV_NAME}
else
  eb deploy
fi
