#!/bin/bash
# vim: set foldmethod=marker:

export DOTFILES="$(dirname -- "$(realpath -- "${BASH_SOURCE[0]:-$0}")")"

function exists() {
    command -v $1 >/dev/null 2>&1
}

# cgclassify {{{1
function cgclassify() {
    local cgpaths=() cgpath id subsys hier
    [[ -f /proc/self/cgroup ]] || return
    while IFS=":" read -r id subsys hier; do
        cgpath="/sys/fs/cgroup/${subsys#name=}/shell/bash-$$"
        [[ -d "${cgpath%/*}" && "${hier}" != /shell/* ]] || continue
        cgpaths+=( "${cgpath}" )
    done </proc/self/cgroup
    for cgpath in "${cgpaths[@]}"; do
        mkdir "${cgpath}"
        echo "$$" > "${cgpath}/cgroup.procs"
        echo 1 > "${cgpath}/notify_on_release"
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
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
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
POWERPROMPT_OPTS=()

function nopowerline() {
    POWERPROMPT_OPTS+=( '-P' )
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
    PS1="$(powerprompt -f bash -L "${POWERPROMPT_OPTS[@]}" "${segments[@]}") "
}

if exists powerprompt; then
    PROMPT_COMMAND=__prompt_command
else
    PS1="\[$(tput setaf 2)\]\u \[$(tput setaf 4)\]\W \$\[$(tput sgr0)\] "
fi

# history {{{1
unset HISTFILE
HISTSIZE=10000
HISTIGNORE="&"

# environment variables {{{1
export LANG="ja_JP.UTF-8"
export LC_TIME="en_US.UTF-8"
export LC_MESSAGES="en_US.UTF-8"
export LANGUAGE="en"

export LESS="--no-init --quit-if-one-screen --RAW-CONTROL-CHARS"
export LESSHISTFILE="/dev/null"
