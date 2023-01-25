#!/bin/bash

DOTFILES="$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" && pwd -P)"

IGNORED_TARGETS=(
    '.gitignore'
    'install.sh'
    'zsh/functions'
    'zsh/init.zsh'
)
MAKE_DIRECTORY=(
    'bin'
    'vim/.goenv'
    'vim/.ndenv'
    'vim/.pyenv'
    'vim/.rbenv'
    'vim/.rsenv'
    'zsh'
)

usage() {
    cat >&2 <<'EOF'
Usage: install.sh [-af] [-d DESTDIR] [-t {all|dev,tmux,x11}]

Options:
    -a         prompt before install
    -d         destination directory (default: $HOME)
    -f         force to overwrite an existing destination files
    -t         install targets
EOF
    exit 1
}

overwrite_prompt() {
    local -l choice
    read -r -n 1 -u 3 -p "$1 already exists. overwrite? [y/N]: " choice
    [[ "${choice}" != $'\n' ]] && echo 1>&2
    [[ "${choice}" == y ]]
}

ask_prompt() {
    local -l choice
    read -r -n 1 -u 3 -p "install $1? [Y/n]: " choice
    [[ "${choice}" != $'\n' ]] && echo 1>&2
    [[ "${choice}" != n ]]
}

list_targets() {
    local makedirs dir target pattern
    readarray -t makedirs < <(printf '%s\n' "${MAKE_DIRECTORY[@]}" \
        | sed -n -e 'p;:a' -e '/\//{s:/[^/]*$::;p;ta;}' | sort -ur)
    git -C "${DOTFILES}" ls-files -co | while IFS= read -r target; do
        [[ -f "${DOTFILES}/${target}" ]] || continue
        for pattern in "${IGNORED_TARGETS[@]}"; do
            [[ "${target}/" == "${pattern}"/* ]] && continue 2
        done
        for dir in "${makedirs[@]}"; do
            [[ "${target}/" == "${dir}"/* ]] || continue
            target="${target#"${dir}"/}"
            echo "${dir}/${target%%/*}"
            continue 2
        done
        echo "${target%%/*}"
    done | sort -u
}

OPT_ASK=0
OPT_FORCE=0
DESTDIR="${HOME}"
TARGETS=""
while getopts :afd:t: opt; do
    case "${opt}" in
        a) OPT_ASK=1 ;;
        f) OPT_FORCE=1 ;;
        d) DESTDIR="${OPTARG}" ;;
        t)
            if [[ "${OPTARG}" == all ]]; then
                TARGETS="dev,tmux,x11"
            else
                TARGETS="${OPTARG}"
            fi
            ;;
        *) usage ;;
    esac
done
(( OPT_FORCE )) && OPT_ASK=0

if [[ ",${TARGETS}," != *,dev,* ]]; then
    IGNORED_TARGETS+=( bin/git-delta gitconfig gitignore )
    IGNORED_TARGETS+=( vim/.goenv vim/.ndenv vim/.pyenv vim/.rbenv vim/.rsenv )
    IGNORED_TARGETS+=( vim/devplugins.toml vim/efm-langserver.yaml )
fi
if [[ ",${TARGETS}," != *,tmux,* ]]; then
    IGNORED_TARGETS+=( tmux tmux.conf )
fi
if [[ ",${TARGETS}," != *,x11,* ]]; then
    IGNORED_TARGETS+=( xprofile )
fi

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
