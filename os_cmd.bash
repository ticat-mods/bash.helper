function check_or_install()
{
	local to_check="${1}"
	if [ -z "${2+x}" ]; then
		local to_install="${to_check}"
	else
		local to_install="${2}"
	fi

	local pms=(
		'yum'
		'apt-get'
		'brew'
	)

	if ! [ -x "$(command -v ${to_check})" ]; then
		echo "[:-] command ${to_check} not found"

		local ok='false'
		for pm in "${pms[@]}"; do
			if [ -x "$(command -v ${pm})" ]; then
				echo "[:-] will install ${to_install} using ${pm}"
				${pm} install -y "${to_install}"
				if [[ $? > 0 ]]; then
					echo "[:(] installation failed"
					exit 1
				else
					echo "[:)] installed ${to_install}"
					ok='true'
					break 1
				fi
			fi
		done

		if [ "${ok}" != 'true' ]; then
			echo "[:(] no supported package manager found, please install ${to_install}(${to_check}) manually"
			exit 2
		fi
	else
		echo "[:)] command ${to_check} installed"
	fi
}
