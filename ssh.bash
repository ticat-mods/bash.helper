function ssh_ping()
{
	local host="${1}"
	if [ ! -z "${2+x}" ]; then
		local user="${2}"
	else
		local user=`whoami`
	fi
	local result=`ssh_exe "${host}" "echo \"hello\"" "${user}" 2>/dev/null | { grep 'hello' || test $? = 1; }`
	if [ -z "${result}" ]; then
		echo 'false'
	else
		echo 'true'
	fi
}

function ssh_exe()
{
	local host="${1}"
	local cmd="${2}"
	if [ ! -z "${3+x}" ]; then
		local user="${3}"
	else
		local user=`whoami`
	fi
	#ssh -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" -o "BatchMode=yes" "${host}" ${cmd} </dev/null
	ssh -o "StrictHostKeyChecking=no" -o "BatchMode=yes" "${user}@${host}" ${cmd} </dev/null
}
