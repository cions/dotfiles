#!/bin/bash
# vim: set foldmethod=marker:

export DOTFILES="$(dirname -- "$(realpath -- "${BASH_SOURCE[0]:-$0}")")"

function exists() {
    command -v $1 >/dev/null 2>&1
}

# cgclassify {{{1
function cgclassify() {
    local cgroups=() cgroup cgpath id subsys hier
    [[ -f /proc/self/cgroup ]] || return
    readarray -t cgroups < /proc/self/cgroup
    for cgroup in "${cgroups[@]}"; do
        IFS=":" read -r id subsys hier <<< "${cgroup}"
        cgpath="/sys/fs/cgroup/${subsys#name=}/shell/bash-$$"
        [[ -d "${cgpath%/*}" && "${hier}" != /shell/* ]] || continue
        mkdir -- "${cgpath}" 2>/dev/null || continue
        echo "$$" > "${cgpath}/cgroup.procs"
        echo 1 > "${cgpath}/notify_on_release"
        [[ -f "${cgpath}/freezer.state" ]] \
            && chgrp wheel "${cgpath}/freezer.state" \
            && chmod g+w "${cgpath}/freezer.state"
        [[ -f "${cgpath}/pids.max" ]] && echo 1024 > "${cgpath}/pids.max"
    done
} && cgclassify
unset -f cgclassify

# dircolors {{{1
if exists dircolors; then
    if [[ -f ~/.dir_colors ]]; then
        eval "$(dircolors -b ~/.dir_colors)"
    elif [[ -f /etc/DIR_COLORS ]]; then
        eval "$(dircolors -b /etc/DIR_COLORS)"
    else
        eval "$(dircolors -b)"
    fi
fi

# options {{{1
shopt -s dotglob
shopt -s nullglob
shopt -s checkwinsize
shopt -s no_empty_cmd_completion

# aliases {{{1
alias ls='ls -F --color=auto --quoting-style=literal'
alias la='ls -aF --color=auto --quoting-style=literal'
alias lA='ls -AF --color=auto --quoting-style=literal'
alias ll='ls -AlF --color=auto --time-style=long-iso --quoting-style=literal'
alias grep='grep -E --color=auto'
alias cpi='cp -i'
alias mvi='mv -i'
alias rmi='rm -i'
alias rr='rm -rf'
alias dot='git -C "${DOTFILES}"'
exists hub && alias git='hub'

# key bindings {{{1
bind C-F:menu-complete
bind C-B:menu-complete-backward

# prompt {{{1
PLAIN_PS1="\[\e[0m\e[32m\]\u \[\e[34m\]\W \$\[\e[39m\] "

function nopowerline() {
    unset PROMPT_COMMAND
    PS1="${PLAIN_PS1}"
}

function __prompt_command() {
    local exitcode=$?
    local jobnum=$(jobs -p | wc -l)
    local segments=()

    if (( exitcode != 0 )); then
        segments+=( "red:${exitcode}" )
    fi
    if (( jobnum != 0 )); then
        segments+=( "orange:${jobnum}" )
    fi
    segments+=( "magenta:bash" )
    if (( EUID == 0 )); then
        segments+=( "magenta:\u" )
    else
        segments+=( "green:\u" )
    fi
    if [[ -n ${SSH_CONNECTION+set} ]]; then
        segments+=( "yellow:\H" )
    fi
    segments+=( "gray3:\W" )
    PS1="\[\e[0m\]$(powerprompt -f bash -L "${segments[@]}") "
}

if exists powerprompt; then
    PROMPT_COMMAND=__prompt_command
else
    PS1="${PLAIN_PS1}"
fi

# history {{{1
unset HISTFILE
HISTSIZE=10000
HISTIGNORE="&"

# environment variables {{{1
export LANG="ja_JP.UTF-8"
export LC_TIME="en_US.UTF-8"
export LC_MESSAGES="en_US.UTF-8"
export LANGUAGE="en_US"

export LESS="--no-init --quit-if-one-screen --RAW-CONTROL-CHARS"
export LESSHISTFILE="/dev/null"
