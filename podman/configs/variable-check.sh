#!/usr/bin/env bash

function check_required_variables() {
	REQUIRED_VARS=(
		bind_mount
		redis_pass
		mariadb_root_pass
		mariadb_user
		mariadb_user_pass
		mysql_user
		mysql_user_pass
		mysql_image
		nc_admin_user
		nc_admin_user_pass
		nc_overwrite_host
		nc_trusted_domains
		nc_image
		psql_user
		psql_pass
		psql_image
		pgadmin_email
		pgadmin_password
		pgadmin_image
		forgejo_server_domain
		forgejo_server_root_url
		forgejo_db_host
		forgejo_db_user
		forgejo_db_pass
		forgejo_image
		mongo_root_pass
		mongo_image
		nginx_image
	)

	for var in "${REQUIRED_VARS[@]}"; do
		# ${!var} expands to the value of the variable whose name is in $var
		if [[ -z "${!var:-}" ]]; then
			echo "❌ ERROR: Environment variable '$var' is unset or empty."
			exit 1
		fi
	done
}

