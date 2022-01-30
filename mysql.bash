function my_exe()
{
	local host="${1}"
	local port="${2}"
	local user="${3}"
	local db="${4}"
	local query=`echo "${5}" | awk '$1=$1'`
	mysql -h "${host}" -P "${port}" -u "${user}" --database="${db}" -e "${query}"
}

function my_ensure_db()
{
	local host="${1}"
	local port="${2}"
	local user="${3}"
	local db="${4}"
	local query="CREATE DATABASE IF NOT EXISTS ${db}"
	mysql -h "${host}" -P "${port}" -u "${user}" -e "${query}"
}
