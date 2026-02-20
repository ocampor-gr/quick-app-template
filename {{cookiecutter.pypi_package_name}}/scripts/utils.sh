create-env-list() {
    local vars=("$@")
    local env_list=""

    for var in "${vars[@]}"; do
        local value=$(printenv "$var")
        if [[ -z "$env_list" ]]; then
            env_list="$var=$value"
        else
            env_list="$env_list,$var=$value"
        fi
    done

    echo "${env_list}"
}

print-env-url() {
  local env_name=${1}
  local cname=$(aws elasticbeanstalk describe-environments \
    --environment-names "${env_name}" \
    --query 'Environments[0].CNAME' \
    --output text)

  echo "${cname:-localhost}"
}
