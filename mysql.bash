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

	set +e
	MYSQL_PWD="${pp}" mysql -h "${host}" -P "${port}" -u "${user}" --database="${db}" --comments ${fmt} -e "${query}"
	local rt="${?}"
	set -e
	if [ "${rt}" == '0' ]; then
		return 0
	fi

	echo "***" >&2
	echo "host: ${host}" >&2
	echo "port: ${port}" >&2
	echo "user: ${user}" >&2
	echo "db:   ${db}" >&2
	echo "ca:   ${ca}" >&2
	if [ -z "${pp}" ]; then
		echo 'pwd:  (empty)' >&2
	else
		echo 'pwd:  (not empty)' >&2
	fi
	echo "ERROR QUERY:" >&2
	echo "${query}" >&2
	echo "***" >&2
	return 1
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
