#!/bin/bash
# vim: set foldmethod=marker:

# cgclassify {{{1
cgclassify() {
    local cgpaths=() cgpath id subsys hier
    [[ -f /proc/self/cgroup ]] || return
    while IFS=":" read -r id subsys hier; do
        cgpath="/sys/fs/cgroup/${subsys#name=}/shell/bash-$$"
        [[ -d "${cgpath%/*}" && "${hier}" != /shell/* ]] || continue
        cgpaths+=("${cgpath}")
    done </proc/self/cgroup
    for cgpath in "${cgpaths[@]}"; do
        mkdir "${cgpath}"
        echo "$$" | tee "${cgpath}/cgroup.procs" >/dev/null
        echo 1 | tee "${cgpath}/notify_on_release" >/dev/null
    done
}
cgclassify
unset -f cgclassify

# dircolors {{{1
if command -v dircolors >/dev/null; then
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
alias dot='git -C "${HOME}/src/github.com/cions/dotfiles"'
command -v hub >/dev/null && alias git='hub'

# key bindings {{{1
bind C-F:menu-complete
bind C-B:menu-complete-backward

# prompt {{{1
_PROMPT_EXITCODE="\[$(tput setaf 236)$(tput setab 203)\]"
_PROMPT_UNPRIVILEGED="\[$(tput setaf 238)$(tput setab 117)\]"
_PROMPT_PRIVILEGED="\[$(tput setaf 236)$(tput setab 216)\]"
_PROMPT_CWD="\[$(tput setaf 252)$(tput setab 240)\]"
_PROMPT_CLEAR="\[$(tput sgr0)\]"

__prompt_command() {
    local exitcode=$?

    PS1="${_PROMPT_CLEAR}"
    if (( ${exitcode} != 0 )); then
        PS1+="${_PROMPT_EXITCODE} ${exitcode} "
    fi
    if (( ${EUID} == 0 )); then
        PS1+="${_PROMPT_PRIVILEGED}"
    else
        PS1+="${_PROMPT_UNPRIVILEGED}"
    fi
    PS1+=" \u${SSH_CONNECTION+@\H} "
    PS1+="${_PROMPT_CWD} \W ${_PROMPT_CLEAR} "
}
PROMPT_COMMAND=__prompt_command

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
