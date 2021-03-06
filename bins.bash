. "`cd $(dirname ${BASH_SOURCE[0]}) && pwd`/git.bash"

function get_built_bin_path_from_repo()
{
	local env="${1}"
	local repo_addr="${2}"
	local bin_rpath="${3}"

	local cache_dir=`must_env_val "${env}" 'sys.paths.cache'`
	if [ -z "${cache_dir}" ]; then
		return 0
	fi

	local cache_dir="${cache_dir}/repos"
	if [ ! -d "${cache_dir}" ]; then
		return 0
	fi

	local dir_name=`basename "${repo_addr}"`
	local dir_path="${cache_dir}/${dir_name}"
	if [ ! -d "${dir_path}" ]; then
		return 0
	fi

	local bin_path="${dir_path}/${bin_rpath}"
	if [ -f "${bin_path}" ]; then
		echo "${bin_path}"
	fi
}

function build_bin_from_repo()
{
	local env="${1}"
	local repo_addr="${2}"
	local bin_rpath="${3}"

	if [ ! -z "${4+x}" ] && [ ! -z "${4}" ]; then
		local make_cmd="${4}"
	else
		local make_cmd='make'
	fi

	local cache_dir=`must_env_val "${env}" 'sys.paths.cache'`
	if [ -z "${cache_dir}" ]; then
		echo "[:(] can't get 'sys.paths.cache' from env" >&2
		return 1
	fi
	local cache_dir="${cache_dir}/repos"
	mkdir -p "${cache_dir}"

	local dir_name=`basename "${repo_addr}"`
	local dir_path="${cache_dir}/${dir_name}"
	if [ ! -e "${dir_path}" ]; then
		(
			cd "${cache_dir}" && git clone "${repo_addr}"
		)
	fi

	local bin_path="${dir_path}/${bin_rpath}"
	if [ -f "${bin_path}" ]; then
		echo "${bin_path}"
		return 0
	fi

	(
		cd "${dir_path}"
		${make_cmd} 1>&2
		if [ ! -f "${bin_path}" ]; then
			echo "[:(] can't build '${bin_path}' from build dir: '${dir_path}'" >&2
			return 1
		fi
		echo "[:)] built '${bin_rpath}' in build dir: '${dir_path}'" >&2
	)

	echo "${bin_path}"
}

function download_or_build_bin()
{
	local env="${1}"
	local repo_addr="${2}"
	local bin_rpath="${3}"

	if [ ! -z "${4+x}" ] && [ ! -z "${4}" ]; then
		local make_cmd="${4}"
	else
		local make_cmd='make'
	fi

	if [ -z "${5+x}" ]; then
		local download_token=''
	else
		local download_token="${5}"
	fi

	local cache_dir=`must_env_val "${env}" 'sys.paths.cache'`
	if [ -z "${cache_dir}" ]; then
		echo "[:(] can't get 'sys.paths.cache' from env" >&2
		return 1
	fi
	local cache_dir="${cache_dir}/download"
	mkdir -p "${cache_dir}"

	local bin_name=`basename "${bin_rpath}"`
	local download_path="${cache_dir}/${bin_name}"
	if [ -f "${download_path}" ]; then
		echo "${download_path}"
		echo "[:)] use previous downloaded '${download_path}'" >&2
		return 0
	fi

	local built_bin=`get_built_bin_path_from_repo "${env}" "${repo_addr}" "${bin_rpath}"`
	if [ ! -z "${built_bin}" ]; then
		echo "${built_bin}"
		echo "[:)] use previous built '${built_bin}'" >&2
		return 0
	fi

	local ok=`download_bin_from_gitpage_release "${repo_addr}" "${bin_name}" "${cache_dir}" "${download_token}"`
	if [ "${ok}" == 'true' ]; then
		echo "${download_path}"
		echo "[:)] downloaded '${download_path}'" >&2
	else
		build_bin_from_repo "${env}" "${repo_addr}" "${bin_rpath}" "${make_cmd}"
	fi
}
