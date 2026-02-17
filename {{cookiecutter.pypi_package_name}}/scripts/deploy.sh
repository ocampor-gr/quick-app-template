source "./scripts/utils.sh"

ENV_NAME="{{cookiecutter.eb_app_name}}"
APPS=$(eb list)

GOOGLE_CLIENT_ID=${GOOGLE_CLIENT_ID:-"client-id-is-missing"}
GOOGLE_CLIENT_SECRET=${GOOGLE_CLIENT_SECRET:-"client-secret-is-missing"}
AUTH_SECRET=$(openssl rand -base64 32)
AUTH_URL="http://2026-goals.eba-sjtckyan.us-east-2.elasticbeanstalk.com"
NEXT_PUBLIC_BACKEND_URL="http://2026-goals.eba-sjtckyan.us-east-2.elasticbeanstalk.com/api/v1"
ALLOWED_DOMAIN=${ALLOWED_DOMAIN:-"graphitehq.com"}
ENV_VARS=$(create-env-list "GOOGLE_CLIENT_ID" "GOOGLE_CLIENT_SECRET" "AUTH_SECRET" "AUTH_URL" "NEXT_PUBLIC_BACKEND_URL" "ALLOWED_DOMAIN")

if [ -z "${APPS}" ]; then
  # staging VPC
  # staging load balance sg
  eb create ${ENV_NAME} \
      -i t3.large \
      --vpc.id vpc-0865d0fe1685e07c6 \
      --vpc.ec2subnets subnet-0f51fe4df99eafc89,subnet-09ed0579b716d86e3 \
      --vpc.elbsubnets subnet-0ffba3b26556c0a4d,subnet-0089669023c7960a1 \
      --vpc.securitygroups sg-01b0628a487f58d2b \
      --vpc.elbpublic \
      --envvars "${ENV_VARS}"
else
  eb deploy
fi
