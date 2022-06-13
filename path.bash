function abs_path()
{
	if [ -z ${1+x} ]; then
		echo "[func abs_path] usage: <func> src_path" >&2
		return 1
	fi

	local src="${1}"

	if [ "${src:0:1}" == '/' ]; then
		echo "${src}"
		return
	fi

	if [ `uname` == "Darwin" ]; then
		if [ -d "${src}" ]; then
			local path=$(cd "${src}"; pwd)
		elif [ -f "${src}" ]; then
			local dir=$(cd "$(dirname "${src}")"; pwd)
			local path="${dir}/`basename ${src}`"
		else
			echo "`pwd`/${src}"
			return 1
		fi
		echo "${path}"
	else
		readlink -f "${src}"
	fi
}
