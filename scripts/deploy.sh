APP_NAME=docker-compose-tutorial
APPS=$(eb list)

if [ -z "${APPS}" ]; then
  eb create ${APP_NAME}
else
  eb deploy
fi
