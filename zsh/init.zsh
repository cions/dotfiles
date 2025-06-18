() {
	local zshdir dir func

	zshdir=${${(%):-%x}:A:h}
	for dir in ${zshdir}/*(nN-/); do
		fpath=( ${dir} ${fpath} )
		for func in ${dir}/*(N-.:t); do
			autoload -Uz ${func}
			[[ ${func} == zle-* ]] && zle -N ${func}
		done
	done
}
