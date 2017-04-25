() {
    local zshdir dir func

    zshdir=${${(%):-%x}:A:h}
    for dir in ${zshdir}/*(N-/); {
        fpath=( ${dir} ${fpath} )
        for func in ${dir}/*(N-.:t); {
            autoload -Uz ${func}
            if [[ ${func} == zle-* ]] zle -N ${func}
        }
    }
}
