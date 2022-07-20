function to_true()
{
	local val="${1}"
	local trues=('true' 't' 'yes' 'y' 'on' '1')
	for t in ${trues[@]}; do
		if [ "${t}" == "${val}" ]; then
			echo 'true'
			return 0
		fi
	done
	echo 'false'
}

function to_false()
{
	local val="${1}"
	local trues=('false' 'f' 'no' 'n' 'off' '0')
	for t in ${trues[@]}; do
		if [ "${t}" == "${val}" ]; then
			echo 'false'
			return 0
		fi
	done
	echo 'true'
}

function is_number()
{
	local str="${1}"
	if [ "${str}" -ge 0 ] 2>/dev/null; then
		echo 'true'
	else
		if [ "${str}" -lt 0 ] 2>/dev/null; then
			echo 'true'
		else
			echo 'false'
		fi
	fi
}

function lines_to_list()
{
	local lines="${1}"
	readarray -t ARRAY <<< "${lines}"; IFS=','; echo "${ARRAY[*]}"
}

function list_to_array()
{
	local list="${1}"
	echo "${list}" | tr ',' "\n"
}

function normalize_github_addr()
{
	local addr="${1}"
	local addr_check=`echo "${addr}" | { grep 'http' || test $? = 1; }`
	if [ ! -z "${addr_check}" ]; then
		echo "${addr}"
		return 0
	fi
	local addr_check=`echo "${addr}" | { grep '@' || test $? = 1; }`
	if [ ! -z "${addr_check}" ]; then
		echo "${addr}"
		return 0
	fi
	echo "https://github.com/${addr}"
}

function extract_lines_section()
{
	local lines="${1}"
	local section="${2}"
	local next_sect=''
	if [ ! -z "${3+x}" ]; then
		local next_sect="${3}"
	fi
	local lines=`echo "${lines}" |\
		{ grep -A 999999 "${section}" || test $? = 1; } |\
		{ grep -v "${section}" || test $? = 1; } |\
		{ grep -v '\-\-\-\-' || test $? = 1; }`
	if [ ! -z "${next_sect}" ]; then
		local lines=`echo "${lines}" |\
			{ grep -B 999999 "${next_sect}" || test $? = 1; } |\
			{ grep -v "${next_sect}" || test $? = 1; }`
	fi
	echo "${lines}"
}
