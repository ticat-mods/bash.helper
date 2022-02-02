function my_exe()
{
	local host="${1}"
	local port="${2}"
	local user="${3}"
	local db="${4}"
	local query=`echo "${5}" | awk '$1=$1'`

	local fmt=''
	if [ ! -z "${6+x}" ]; then
		local fmt="${6}"
	fi
	if [ "${fmt}" == 'v' ]; then
		local fmt='--vertical'
	fi
	if [ "${fmt}" == 'tab' ]; then
		local fmt='--batch'
	fi
	if [ "${fmt}" == 't' ]; then
		local fmt='--table'
	fi
	if [ -z "${fmt}" ]; then
		local fmt='--table'
	fi

	mysql -h "${host}" -P "${port}" -u "${user}" --database="${db}" --comments ${fmt} -e "${query}"
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
