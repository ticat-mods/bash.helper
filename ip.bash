function get_ips()
{
	ifconfig | { grep 'en[0123456789]\|eth[0123456789]\|wlp[0123456789]\|em[0123456789]' -A 3 || test $? = 1; } | \
		{ grep -v inet6 || test $? = 1; } | { grep inet || test $? = 1; } | { grep -i mask || test $? = 1; } | awk '{print $2}'
}

function get_ips_cnt()
{
	local ips="`get_ips`"
	if [ -z "${ips}" ]; then
		echo "0"
	else
		echo "${ips}" | wc -l | awk '{print $1}'
	fi
}

function get_ip_or_host()
{
	local ip_cnt="`get_ips_cnt`"
	if [ "${ip_cnt}" == '0' ]; then
		hostname
	else
		get_ips | head -n 1
	fi
}
