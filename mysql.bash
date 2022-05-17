function my_exe()
{
	local host="${1}"
	local port="${2}"
	local user="${3}"
	local pp="${4}"
	local db="${5}"
	local query=`echo "${6}" | awk '$1=$1'`

	local fmt=''
	if [ ! -z "${7+x}" ]; then
		local fmt="${7}"
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

	MYSQL_PWD="${pp}" mysql -h "${host}" -P "${port}" -u "${user}" --database="${db}" --comments ${fmt} -e "${query}"
}

function my_ensure_db()
{
	local host="${1}"
	local port="${2}"
	local user="${3}"
	local pp="${4}"
	local db="${5}"
	local query="CREATE DATABASE IF NOT EXISTS ${db}"
	MYSQL_PWD="${pp}" mysql -h "${host}" -P "${port}" -u "${user}" -e "${query}"
}
