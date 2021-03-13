#!/bin/bash
# vim: set foldmethod=marker:

# preamble {{{1
DOTFILES="$(dirname -- "$(readlink -- "${BASH_SOURCE[0]:-$0}")")"

exists() {
    command -v -- "$1" >/dev/null 2>&1
}

# options {{{1
shopt -s checkwinsize
shopt -s dotglob
shopt -s no_empty_cmd_completion
shopt -s globstar
shopt -s lithist
shopt -s nullglob

HISTCONTROL=ignoreboth
HISTSIZE=10000
unset HISTFILE

# commands {{{1
args() {
    printf '%s\n' "${@@Q}"
}

mkcd() {
    # shellcheck disable=SC2164
    mkdir -p -- "$1" && cd -- "$1"
}

rr() {
    local -l ans
    echo rm -rf "$@"
    read -r -p 'execute? ' ans
    case "${ans}" in
        y|yes) command rm -rf "$@" ;;
    esac
}

bak() {
    local file
    for file; do
        mv -i "${file}" "${file}.bak"
    done
}

# aliases {{{1
if exists exa; then
    alias ls='exa --classify --sort=Name'
    alias la='exa --classify --sort=Name --all'
    alias lA='exa --classify --sort=Name --all'
    alias lt='exa --classify --sort=Name --all --tree'
    alias ll='exa --classify --sort=Name --all --long --binary --group --time-style=long-iso'
    alias llt='exa --classify --sort=Name --all --long --tree --binary --group --time-style=long-iso'
elif exists dircolors; then
    alias ls='ls -F --color=auto --quoting-style=literal'
    alias la='ls -AF --color=auto --quoting-style=literal'
    alias lA='ls -AF --color=auto --quoting-style=literal'
    alias ll='ls -AlF --color=auto --quoting-style=literal --time-style=long-iso'
else
    alias ls='ls -F'
    alias la='ls -AF'
    alias lA='ls -AF'
    alias ll='ls -AlF'
fi
alias grep='grep -E --color=auto'
alias rga="rg --hidden --glob='!.git/'"
alias reload='exec bash'
alias dot='git -C "${DOTFILES}"'
alias gdiff='git diff --no-index'

# key bindings {{{1
bind C-F:menu-complete
bind C-B:menu-complete-backward

# PROMPT_COMMAND {{{1
_PROMPT_COMMANDS=()
_prompt_command() {
    local status=$? func
    for func in "${_PROMPT_COMMANDS[@]}"; do
        ${func} ${status}
    done
}
PROMPT_COMMAND=_prompt_command

# prompt {{{1
_prompt_width() {
    echo -n "${PS1@P}" | sed $'s/\x01[^\x02]*\x02//g' | wc -L
}

_prompt_default() {
    local segments=()
    local status=$1
    local jobnum

    if (( status != 0 )); then
        segments+=( "red:${status}" )
    fi
    jobnum="$(jobs -p | wc -l)"
    if (( jobnum != 0 )); then
        segments+=( "orange:${jobnum}" )
    fi
    segments+=( "magenta:\\s" )
    if (( EUID == 0 )); then
        segments+=( "magenta:\\u" )
    else
        segments+=( "green:\\u" )
    fi
    if [[ -v SSH_CONNECTION ]]; then
        segments+=( "yellow:\\H" )
    fi
    segments+=( "gray3:\\W" )
    PS1="$(powerprompt -f bash -L -- "${segments[@]}") "

    local width padded
    width="$(_prompt_width)"
    printf -v padded "%*s" $((width-4)) "..."
    PS2="$(powerprompt -f bash -L -- "gray3:${padded}") "
}

_prompt_simple() {
    local RESET
    local -A FG
    local status=$1

    RESET="\e[0m"
    FG=(
        [black]="\e[30m"
        [red]="\e[31m"
        [green]="\e[32m"
        [yellow]="\e[33m"
        [blue]="\e[34m"
        [magenta]="\e[35m"
        [cyan]="\e[36m"
        [white]="\e[37m"
    )

    PS1="\\[${RESET}\\]"
    if (( status != 0 )); then
        PS1+="\\[${FG[red]}\\](${status}) "
    fi
    PS1+="\\[${FG[green]}\\]\\u"
    if [[ -v SSH_CONNECTION ]]; then
        PS1+="\\[${FG[yellow]}\\]@\\H"
    fi
    PS1+="\\[${FG[blue]}\\] \\W \\$\\[${RESET}\\] "

    local width padded
    width="$(_prompt_width)"
    printf -v padded "%*s" $((width-2)) "..."
    PS2="\\[${RESET}${FG[blue]}\\]${padded}>\\[${RESET}\\] "
}

prompt() {
    local style="${1:-default}"

    if [[ "${style}" == default ]]; then
        exists powerprompt || style=simple
        exists /bin/zsh || style=simple
    fi

    case "${style}" in
        default)
            _PROMPT_COMMANDS=( "${_PROMPT_COMMANDS[@]/_prompt_*/_prompt_default}" )
            ;;
        *)
            _PROMPT_COMMANDS=( "${_PROMPT_COMMANDS[@]/_prompt_*/_prompt_simple}" )
            ;;
    esac
}

_PROMPT_COMMANDS+=( _prompt_simple )
if (( ENABLE_ICONS )); then
    prompt default
fi

# gpg-agent {{{1
if exists gpgconf; then
    unset SSH_AGENT_PID
    SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
    GPG_TTY="$(tty)"
    export SSH_AUTH_SOCK GPG_TTY

    _gpg_agent_updatestartuptty() {
        ( gpg-connect-agent updatestartuptty /bye >/dev/null 2>&1 & )
    }
    _PROMPT_COMMANDS+=( _gpg_agent_updatestartuptty )
fi

# dircolors {{{1
if exists dircolors; then
    if [[ -f ~/.dircolors ]]; then
        eval "$(dircolors -b ~/.dircolors)"
    elif [[ -f /etc/DIR_COLORS ]]; then
        eval "$(dircolors -b /etc/DIR_COLORS)"
    else
        eval "$(dircolors -b)"
    fi
fi

# environment variables {{{1
export LANG="ja_JP.UTF-8"
export LC_TIME="en_US.UTF-8"
export LC_MESSAGES="en_US.UTF-8"
export LANGUAGE="en_US"

export EDITOR="vim"
export VISUAL="vim"
export PAGER="less"

export LESS="-FMRSgi -j.5 -z-4"
export LESSHISTFILE="-"

export JQ_COLORS="2;39:0;31:0;31:0;36:0;32:1;39:1;39"

export GOPATH="${HOME}/.cache/go"
export GOBIN="${HOME}/.bin"
