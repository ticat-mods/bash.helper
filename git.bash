function download_bin_from_gitpage_release()
{
	local repo="${1}"
	local bin_name="${2}"
	local dir="${3}"

	if [ ! -z "${4+x}" ] && [ ! -z "${4}" ]; then
		local token="${4}"
		# this code assume the token format are github's
		local token="ghp_${token#'ghp_'}"
	else
		local token=''
	fi

	local repo=`echo "${repo#'https://'}" | awk -F '/' '{print $1"/repos/"$2"/"$3}'`

	if [ ! -z "${token}" ]; then
		local token="Authorization: token ${token}"
	fi

	local os_type=`uname | awk '{print tolower($0)}'`
	echo "[:-] detected os type: ${os_type}" >&2

	local long_name="pre-built bin '${bin_name}' on '${repo}' for '${os_type}'"

	if ! [ -x "$(command -v curl)" ]; then
		echo "[:(] 'curl' not found, please install it first" >&2
		return 1
	fi

	# this code assume the url address format are github's
	local res_addr="https://api.${repo}/releases/latest"

	local json=`curl --proto '=https' --tlsv1.2 -sSf -H "${token}" "${res_addr}"`

	echo "curl --proto '=https' --tlsv1.2 -sSf -H '${token}' '${res_addr}'" >&2

	local ver=`echo "${json}" | { grep '"tag_name": ' || test $? = 1; } | awk -F '"' '{print $(NF-1)}'`
	if [ -z "${ver}" ]; then
		echo "***" >&2
		echo "${json}" >&2
		echo "***" >&2
		echo "[:(] ${long_name} version not found or can't be downloaded, exiting" >&2
		return 1
	fi

	local info=`echo "${json}" | \
		{ grep '"assets": ' -A 99999 || test $? = 1; } | \
		{ grep '"name": \|"browser_download_url": ' || test $? = 1; } | \
		{ grep "${bin_name}_${os_type}" || test $? = 1; } | \
			awk -F '": "' '{print $2}' | \
			awk -F '"' '{print $1}'`

	local res_name=`echo "${info}" | { grep -v 'https://' || test $? = 0; }`
	if [ -z "${res_name}" ]; then
		echo "[:(] ${long_name} not found, exiting" >&2
		return 1
	fi

	local cnt=`echo "${res_name}" | wc -l`
	if [ "${cnt}" != '1' ]; then
		echo "***" >&2
		echo "${res_name}" | awk '{print "   - "$0}' >&2
		echo "***" >&2
		echo "[:(] error: more than one (${cnt}) resource of ${long_name}, exiting" >&2
		return 1
	fi

	local download_url=`echo "${info}" | tail -n 1`

	local hash_val=`echo "${res_name}" | awk -F '_' '{print $NF}' | awk -F '.' '{print $1}'`
	local hash_bin=`echo "${res_name}" | awk -F '_' '{print $(NF-1)}'`

	local bin_path="${dir}/${bin_name}"

	echo "[:)] located version ${ver}: ${long_name}" >&2
	echo "   - ${hash_bin}: ${hash_val}" >&2
	echo "   - url: ${download_url}" >&2
	echo "   - download to: ${bin_path}" >&2

	mkdir -p "${dir}"
	curl --proto '=https' --tlsv1.2 -sSf -kL -H "${token}" "${download_url}" > "${bin_path}.tmp"
	chmod +x "${bin_path}.tmp"
	rm -f "${bin_path}"
	mv "${bin_path}.tmp" "${bin_path}"

	if [ -x "$(command -v ${hash_bin})" ]; then
		local hash_new=`"${hash_bin}" "${bin_path}" | awk '{print $1}'`
		if [ "${hash_new}" != "${hash_val}" ]; then
			echo "[:(] hash value not matched, download failed" >&2
			echo "   - downloaded: ${has_new}" >&2
			return 1
		fi
	fi

	echo 'true'
}

function find_repo_root_dir()
{
	local curr_dir="${1}"
	if [ "${curr_dir}" == '/' ] || [ "${curr_dir}" == '\' ]; then
		return 0
	fi
	if [ -d "${curr_dir}/.git" ]; then
		echo "${curr_dir}"
		return 0
	fi
	local sub=`dirname "${curr_dir}"`
	find_repo_root_dir "${sub}"
}

function _rel_path_to_repo_root()
{
	local curr_dir="${1}"
	local repo_root="${2}"
	local curr_rel="${3}"
	echo "${curr_rel}"
	if [ "${curr_dir}" == "${repo_root}" ]; then
		return 0
	fi
	_rel_path_to_repo_root `dirname "${curr_dir}"` "${repo_root}" "${curr_rel}/.."
}

function rel_path_to_repo_root()
{
	local curr_dir="${1}"
	local repo_root="${2}"
	local lines=`_rel_path_to_repo_root "${curr_dir}" "${repo_root}" '.'`
	if [ -z "${lines}" ]; then
		echo "[:(] something wrong, '${curr_dir}' is not a dir as expected" >&2
		return 1
	fi
	echo "${lines}" | tail -n 1
}
