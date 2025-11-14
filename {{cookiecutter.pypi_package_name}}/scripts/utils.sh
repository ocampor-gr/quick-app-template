create_env_list() {
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
