create-env-list() {
    local vars=("$@")
    local env_list=""

    for var in "${vars[@]}"; do
        if [[ -n "${!var}" ]]; then
            if [[ -z "$env_list" ]]; then
                env_list="$var=${!var}"
            else
                env_list="$env_list,$var=${!var}"
            fi
        fi
    done

    echo "${env_list}"
}

print-env-url() {
  local env_name=${1}
  local cname=$(aws elasticbeanstalk describe-environments \
    --environment-names "${env_name}" \
    --query '.Environments[0].CNAME')

  echo "${cname:-"http://localhost:3000"}"
}
