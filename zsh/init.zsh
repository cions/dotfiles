() {
    local zshdir dir func

    zshdir=${${(%):-%x}:A:h}
    for dir in ${zshdir}/*(N-/); do
        fpath=( ${dir} ${fpath} )
        for func in ${dir}/*(N-.:t); do
            autoload -Uz ${func}
            [[ ${func} == zle-* ]] && zle -N ${func}
        done
    done
}
