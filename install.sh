#!/bin/bash

DOTFILES="$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" && pwd -P)"

IGNORED_TARGETS=(
    'install.sh'
    'zsh/functions'
    'zsh/init.zsh'
)
MAKE_DIRECTORY=(
    'vim/.pyenv'
    'vim/.ndenv'
    'zsh'
)

usage() {
    echo "usage: $0 [-af] [DESTDIR]"
    echo
    echo "Options:"
    echo " -a       prompt before install"
    echo " -f       force to overwrite an existing destination files"
    exit 1
} 1>&2

overwrite_prompt() {
    local -l choice
    read -r -n 1 -u 3 -p "$1 already exists. overwrite? [y/N]: " choice
    echo 1>&2
    [[ "${choice}" == y ]]
}

ask_prompt() {
    local -l choice
    read -r -n 1 -u 3 -p "install $1? [Y/n]: " choice
    echo 1>&2
    [[ "${choice}" != n ]]
}

list_targets() {
    local makedirs dir target pattern
    readarray -t makedirs < <(printf '%s\n' "${MAKE_DIRECTORY[@]}" \
        | sed -n -e 'p;:a' -e '/\//{s:/[^/]*$::;p;ta}' | sort -ur)
    git -C "${DOTFILES}" ls-files -co | while IFS= read -r target; do
        for pattern in "${IGNORED_TARGETS[@]}"; do
            [[ "${target}/" == "${pattern}"/* ]] && continue 2
        done
        for dir in "${makedirs[@]}"; do
            [[ "${target}/" == "${dir}"/* ]] || continue
            target="${target#${dir}/}"
            echo "${dir}/${target%%/*}"
            continue 2
        done
        echo "${target%%/*}"
    done | sort -u
}

OPT_ASK=0
OPT_FORCE=0
DESTDIR="${HOME}"
while getopts :af opt; do
    case "${opt}" in
        a) OPT_ASK=1 ;;
        f) OPT_FORCE=1 ;;
        *) usage ;;
    esac
done
shift $(( OPTIND - 1 ))
(( $# > 0 )) && DESTDIR="$1"
(( OPT_FORCE )) && OPT_ASK=0

exec 3<&0
list_targets | while IFS= read -r target; do
    src="${DOTFILES}/${target}"
    dst="${DESTDIR}/.${target}"
    [[ "${src}" -ef "${dst}" ]] && continue
    if [[ -e "${dst}" ]]; then
        if (( OPT_FORCE )) || overwrite_prompt "${dst}"; then
            rm -r -- "${dst}" || exit 1
        else
            continue
        fi
    elif (( OPT_ASK )) && ! ask_prompt "${dst}"; then
        continue
    fi
    mkdir -p -- "${dst%/*}" && ln -sfT -- "${src}" "${dst}" || exit 1
done
