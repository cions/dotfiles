() {
    local script_dir dir func

    script_dir=${${(%):-%x}:A:h}

    for dir in ${script_dir}/*(N-/); do
        fpath=( ${dir} ${fpath} )
        for func in ${dir}/*(N-.:t); do
            autoload -Uz ${func}
            [[ ${func} == zle-* ]] && zle -N ${func}
        done
    done
}
