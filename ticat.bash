function env_val()
{
	local env="${1}"
	local key="${2}="
	local key_len=${#key}
	local val_line=`echo "${env}" | { grep "^${key}" || test $? = 1; } | tail -n 1`
	local val="${val_line:$key_len}"
	echo "${val}"
}

function env_prefix_keys()
{
	local env="${1}"
	local prefix="${2}"
	local prefix_len=${#prefix}
	local lines=`echo "${env}" | { grep "^${prefix}" || test $? = 1; }`
	echo "${lines}" | while read line; do
		echo "${line}" | awk -F '=' '{print $1}'
	done
}

function env_prefix_kvs()
{
	local env="${1}"
	local prefix="${2}"
	if [ ! -z "${3+x}" ]; then
		local remove_prefix=`to_true "${3}"`
		local prefix_len=${#prefix}
	else
		local remove_prefix='false'
	fi
	local prefix_len=${#prefix}
	local lines=`echo "${env}" | { grep "^${prefix}" || test $? = 1; }`
	if [ "${remove_prefix}" == 'true' ]; then
		echo "${lines}" | while read line; do
			echo "${line:$prefix_len}"
		done
	else
		echo "${lines}"
	fi
}

function must_env_val()
{
	local env="${1}"
	local key="${2}"
	local val=`env_val "${env}" "${key}"`
	if [ -z "${val}" ]; then
		echo "[:(] no env val '${key}'" >&2
		exit 1
	fi
	echo "${val}"
}

function build_bin()
{
	local dir="${1}"
	local bin_path="${2}"
	local make_cmd="${3}"
	(
		cd "${dir}"
		if [ -f "${bin_path}" ]; then
			echo "[:)] found pre-built '${bin_path}' in build dir: '${dir}'" >&2
			return
		fi
		${make_cmd} 1>&2
		if [ ! -f "${bin_path}" ]; then
			echo "[:(] can't build '${bin_path}' from build dir: '${dir}'" >&2
			return 1
		fi
	)
	echo "${dir}/${bin_path}"
}

# TODO: repo may use another default branch name
function _is_default_branch_name()
{
	local branch="${1}"
	if [ "${branch}" == 'main' ] || [ "${branch}" == 'master' ]; then
		echo 'true'
	else
		echo 'false'
	fi
}

function _check_dir_match_git_branch()
{
	local dir="${1}"
	local branch="${2}"
	local treat_no_branch_as_match="${3}"
	(
		cd "${dir}"
		local checking=`git status | head -n 1`

		local no_branch=`echo "${checking}" | { grep 'Not currently on any branch' || test $? == 1; }`
		if [ ! -z "${no_branch}" ]; then
			if [ "${treat_no_branch_as_match}" == 'true' ]; then
				echo 'true'
			else
				echo 'false'
			fi
			return
		fi

		local target=`echo "${checking}" | awk '{print $NF}'`
		if [ -z "${target}" ]; then
			_is_default_branch_name "${target}"
			return
		fi

		if [ "${target}" == "${branch}" ]; then
			echo 'true'
			return
		fi
		if [[ "${#target}" -lt 4 ]] || [[ "${#branch}" -lt 4 ]]; then
			echo 'false'
			return
		fi

		target_len="${#target}"
		if [ "${target}" == "${branch:0:target_len}" ]; then
			echo 'true'
		else
			echo 'false'
		fi
	)
}

function build_bin_in_ticat_shared_dir()
{
	local bin_path_in_repo_dir="${1}"
	local repo="${2}"
	local env="${3}"
	local dir_name="${4}"

	local branch=''
	if [ ! -z "${5+x}" ]; then
		local branch="${5}"
	fi

	local make_cmd='make'
	if [ ! -z "${6+x}" ]; then
		local make_cmd="${6}"
	fi

	local git_hash=''
	if [ ! -z "${7+x}" ]; then
		local git_hash="${7}"
	fi

	local shared_dir=`must_env_val "${env}" 'sys.paths.data.shared'`
	mkdir -p "${shared_dir}"

	local dir="${shared_dir}/${dir_name}"
	if [ -d "${dir}" ]; then
		local branch_for_check="${branch}"
		if [ ! -z "${git_hash}" ]; then
			local branch_for_check="${git_hash}"
		fi
		local same_branch=`_check_dir_match_git_branch "${dir}" "${branch_for_check}" 'true'`
		if [ "${same_branch}" != 'true' ]; then
			echo "[:(] ${dir_name}: exists with another branch, conflicted and aborted" >&2
			return 1
		else
			(
				cd "${dir}"
				echo "(${dir})" >&2
				if [ ! -z "${git_hash}" ]; then
					echo "git checkout ${git_hash}" >&2
					git checkout "${git_hash}" 1>&2
				else
					local is_default_branch=`_is_default_branch_name "${branch}"`
					if [ "${is_default_branch}" == 'true' ]; then
						echo 'git pull' >&2
						git pull 1>&2
					fi
				fi
			)

			build_bin "${dir}" "${bin_path_in_repo_dir}" "${make_cmd}"
		fi
		return
	fi

	(
		echo "(${shared_dir})" >&2
		set -euo pipefail
		cd "${shared_dir}"
		if [ -z "${branch}" ]; then
			echo "git clone ${repo} ${dir_name}" >&2
			git clone "${repo}" "${dir_name}" 1>&2
		else
			echo "git clone ${repo} -b ${branch} ${dir_name}" >&2
			git clone "${repo}" -b "${branch}" "${dir_name}" 1>&2
		fi

		cd "${dir}"
		echo "(${dir})" >&2
		if [ ! -z "${git_hash}" ]; then
			echo "git checkout ${git_hash}" >&2
			git checkout "${git_hash}" 1>&2
		else
			local is_default_branch=`_is_default_branch_name "${branch}"`
			if [ "${is_default_branch}" == 'true' ]; then
				echo 'git pull' >&2
				git pull 1>&2
			fi
		fi

		build_bin "${dir}" "${bin_path_in_repo_dir}" "${make_cmd}"
	)
}
