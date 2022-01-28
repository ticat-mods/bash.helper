function my_exe()
{
	local host="${1}"
	local port="${2}"
	local user="${3}"
	local db="${4}"
	local query="${5}"
	mysql -h "${host}" -P "${port}" -u "${user}" --database="${db}" -e "${query}"
}

function my_ensure_db()
{
	local host="${1}"
	local port="${2}"
	local user="${3}"
	local db="${4}"
	my_exe "${host}" "${port}" "${user}" -e "CREATE DATABASE IF NOT EXISTS ${meta_db}"
}
