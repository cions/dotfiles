#!/bin/bash
# vim: set foldmethod=marker:

# preamble {{{1
DOTFILES="$(dirname -- "$(readlink -- "${BASH_SOURCE[0]:-$0}")")"

exists() {
    command -v -- "$1" >/dev/null 2>&1
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

# PROMPT_COMMAND {{{1
_preprompt_hooks=()
_prompt_command() {
    local func
    for func in "${_preprompt_hooks[@]}"; do
        ${func}
    done
}
PROMPT_COMMAND=_prompt_command

# prompt {{{1
_prompt_width() {
    echo -n "${PS1@P}" | sed 's/\x01[^\x02]*\x02//g' | wc -L
}

_powerprompt() {
    local exitcode=$?
    local jobnum="$(jobs -p | wc -l)"
    local segments=()

    if (( exitcode != 0 )); then
        segments+=( "red:${exitcode}" )
    fi
    if (( jobnum != 0 )); then
        segments+=( "orange:${jobnum}" )
    fi
    segments+=( "magenta:\s" )
    if (( EUID == 0 )); then
        segments+=( "magenta:\u" )
    else
        segments+=( "green:\u" )
    fi
    if [[ -v SSH_CONNECTION ]]; then
        segments+=( "yellow:\H" )
    fi
    segments+=( "gray3:\W" )
    PS1="$(powerprompt -f bash -L -- "${segments[@]}") "

    local width padded
    width="$(_prompt_width)"
    printf -v padded "%*s" $((width-4)) "..."
    PS2="$(powerprompt -f bash -L -- "gray3:${padded}") "
}

_plainprompt() {
    local RESET="$(tput sgr0)"
    local FG_GREEN="$(tput setaf 2)"
    local FG_BLUE="$(tput setaf 4)"

    PS1="\[${RESET}${FG_GREEN}\]\u \[${FG_BLUE}\]\W \$\[${RESET}\] "

    local width padded
    width="$(_prompt_width)"
    printf -v padded "%*s" $((width-2)) "..."
    PS2="\[${RESET}${FG_BLUE}\]${padded}>\[${RESET}\] "
}

nopowerline() {
    _preprompt_hooks=( "${_preprompt_hooks[@]/_powerprompt/_plainprompt}" )
}

if exists powerprompt; then
    _preprompt_hooks+=( _powerprompt )
else
    _preprompt_hooks+=( _plainprompt )
fi

# gpg-agent {{{1
if exists gpgconf; then
    unset SSH_AGENT_PID
    export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
    export GPG_TTY="$(tty)"

    _gpg_agent_updatestartuptty() {
        ( gpg-connect-agent UPDATESTARTUPTTY /bye >/dev/null 2>&1 & )
    }
    _preprompt_hooks+=( _gpg_agent_updatestartuptty )
fi

# environment variables {{{1
export LANG="ja_JP.UTF-8"
export LC_TIME="en_US.UTF-8"
export LC_MESSAGES="en_US.UTF-8"
export LANGUAGE="en_US"

export LESS="--no-init --quit-if-one-screen --RAW-CONTROL-CHARS"
export LESSHISTFILE="/dev/null"
