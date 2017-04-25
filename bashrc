#!/bin/bash
# vim: set foldmethod=marker:

# preamble {{{1
DOTFILES="$(dirname -- "$(readlink -- "${BASH_SOURCE[0]:-$0}")")"

exists() {
    command -v -- "$1" >/dev/null
}

# cgclassify {{{1
cgclassify() {
    local cgroups cgroup cgpath id subsys hier
    [[ -f /proc/self/cgroup ]] || return
    readarray -t cgroups < /proc/self/cgroup
    for cgroup in "${cgroups[@]}"; do
        IFS=":" read -r id subsys hier <<< "${cgroup}"
        cgpath="/sys/fs/cgroup/${subsys#name=}/shell/bash-$$"
        [[ -d "${cgpath%/*}" && "${hier}" != /shell/* ]] || continue
        mkdir "${cgpath}" 2>/dev/null || continue
        echo "$$" > "${cgpath}/cgroup.procs"
        echo 1 > "${cgpath}/notify_on_release"
        if [[ -f "${cgpath}/freezer.state" ]]; then
            chgrp wheel "${cgpath}/freezer.state"
            chmod g+w "${cgpath}/freezer.state"
        fi
        if [[ -f "${cgpath}/pids.max" ]]; then
            echo 1024 > "${cgpath}/pids.max"
        fi
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
shopt -s checkwinsize
shopt -s dotglob
shopt -s no_empty_cmd_completion
shopt -s globstar
shopt -s lithist
shopt -s nullglob

HISTCONTROL=ignoreboth
HISTSIZE=10000
unset HISTFILE

# aliases {{{1
alias ls='ls -F --color=auto --quoting-style=literal'
alias la='ls -aF --color=auto --quoting-style=literal'
alias lA='ls -AF --color=auto --quoting-style=literal'
alias ll='ls -AlF --color=auto --time-style=long-iso --quoting-style=literal'
alias grep='grep -E --color=auto'
alias rm='rm -I'
alias rr='rm -rI'
alias rrf='rm -rf'
alias dot='git -C "${DOTFILES}"'

# key bindings {{{1
bind C-F:menu-complete
bind C-B:menu-complete-backward

# prompt {{{1
FG_NORM="$(tput sgr0)"
FG_GREEN="$(tput setaf 2)"
FG_BLUE="$(tput setaf 4)"
PLAIN_PS1="\[${FG_NORM}${FG_GREEN}\]\u \[${FG_BLUE}\]\W \$\[${FG_NORM}\] "

_prompt_width() {
    echo -n "${PS1@P}" | sed 's/\x01[^\x02]*\x02//g' | wc -L
}

_prompt_command() {
    local exitcode=$?
    local jobnum="$(jobs -p | wc -l)"
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
    if [[ -v SSH_CONNECTION ]]; then
        segments+=( "yellow:\H" )
    fi
    segments+=( "gray3:\W" )
    PS1="\[${FG_NORM}\]$(powerprompt -f bash -L -- "${segments[@]}") "

    local width padded
    width="$(_prompt_width)"
    printf -v padded "%*s" $((width-4)) "cont"
    PS2="\[${FG_NORM}\]$(powerprompt -f bash -L -- "gray3:${padded}") "
}

_aligned_ps2() {
    local width padded
    width="$(_prompt_width)"
    printf -v padded "%*s" $((width-2)) "cont"
    PS2="\[${FG_NORM}${FG_BLUE}\]${padded}>\[${FG_NORM}\] "
}

nopowerline() {
    PS1="${PLAIN_PS1}"
    PROMPT_COMMAND=_aligned_ps2
}

if exists powerprompt; then
    PROMPT_COMMAND=_prompt_command
else
    nopowerline
fi

# environment variables {{{1
export LANG="ja_JP.UTF-8"
export LC_TIME="en_US.UTF-8"
export LC_MESSAGES="en_US.UTF-8"
export LANGUAGE="en_US"

export LESS="--no-init --quit-if-one-screen --RAW-CONTROL-CHARS"
export LESSHISTFILE="/dev/null"
