function to_true()
{
	local val="${1}"
	local trues=('true' 't' 'yes' 'y' 'on' '1')
	for t in ${trues[@]}; do
		if [ "${t}" == "${val}" ]; then
			echo 'true'
			return
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
			return
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
