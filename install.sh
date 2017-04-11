#!/bin/bash

DOTFILES="$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")"; pwd -P)"
IGNORE_PATTERNS=(
    '.*'
    'install.sh'
    'zsh/functions'
)

check_ignore() {
    local pattern
    for pattern in "${IGNORE_PATTERNS[@]}"; do
        [[ "$1" == ${pattern} ]] && return 0
    done
    return 1
}

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

usage() {
    echo "usage: $0 [-af] [DESTDIR]" 1>&2
    echo
    echo "Options:"
    echo " -a       prompt before install"
    echo " -f       force to overwrite an existing destination file"
    exit 1
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

pushd -- "${DOTFILES}" >/dev/null
git ls-files | cut -d '/' -f '1-2' | sort -u | while IFS= read -r target; do
    check_ignore "${target}" && continue
    src="${DOTFILES}/${target}"
    dst="${DESTDIR}/.${target}"
    [[ "${src}" -ef "${dst}" ]] && continue
    if [[ -e "${dst}" ]]; then
        if (( OPT_FORCE )) || overwrite_prompt "${dst}"; then
            rm -rf -- "${dst}"
        else
            continue
        fi
    elif (( OPT_ASK )) && ! ask_prompt "${dst}"; then
        continue
    fi
    mkdir -p -- "${dst%/*}" && ln -sfT -- "${src}" "${dst}"
done
popd >/dev/null
