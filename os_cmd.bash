function check_or_install()
{
	local to_check="${1}"
	if [ -z "${2+x}" ]; then
		local to_install="${to_check}"
	else
		local to_install="${2}"
	fi

	local pms=(
		'yum install -y'
		'apt-get install -y'
		'brew install -y'
		'pacman -S --noconfirm'
		'dnf install -y'
	)

	if ! [ -x "$(command -v ${to_check})" ]; then
		echo "[:-] command ${to_check} not found"

		local ok='false'
		for pm in "${pms[@]}"; do
			local cmd=`echo "${pm}" | awk '{print $1}'`
			if [ -x "$(command -v ${cmd})" ]; then
				echo "[:-] will install '${to_install}' using '${pm}'"
				sudo ${pm} ${to_install}
				if [[ $? > 0 ]]; then
					echo "[:(] installation failed"
					exit 1
				else
					echo "[:)] installed '${to_install}'"
					ok='true'
					break 1
				fi
			fi
		done

		if [ "${ok}" != 'true' ]; then
			echo "[:(] no supported package manager found, please install '${to_install}'(${to_check}) manually"
			exit 2
		fi
	else
		echo "[:)] command ${to_check} installed"
	fi
}

# Refrence: https://stackoverflow.com/questions/14637979/how-to-permanently-set-path-on-linux-unix
function add_bin_dir_to_sys_path()
{
	local bin_dir="${1}"

	local shell=$(echo ${SHELL} | awk 'BEGIN {FS="/";} { print $NF }')
	echo "detected shell: ${shell}"
	if [ -f "${HOME}/.${shell}_profile" ]; then
		local profile=${HOME}/.${shell}_profile
	elif [ -f "${HOME}/.${shell}_login" ]; then
		local profile=${HOME}/.${shell}_login
	elif [ -f "${HOME}/.${shell}rc" ]; then
		local profile=${HOME}/.${shell}rc
	else
		local profile=${HOME}/.profile
	fi
	echo "shell profile:  ${profile}"

	case :${PATH}: in
		*:${bin_dir}:*) : "PATH already contains ${bin_dir}" ;;
		*)  printf '\nexport PATH=%s:$PATH\n' "${bin_dir}" >> "${profile}"
			echo "${profile} has been modified to add '${bin_dir}' to PATH"
			;;
	esac

	echo "installed path: $bin_dir"
}
