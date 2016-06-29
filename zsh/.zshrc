#!/bin/zsh
# vim: foldmethod=marker

export DOTDIR=${${(%):-%x}:A:h:h}

ZTMPDIR="$(mktemp -d ${TEMP:-/tmp}/zsh-XXXXXX)"
trap "rm -rf ${ZTMPDIR}" EXIT

fpath=(${ZDOTDIR}/functions(N-/) $fpath)

# cgclassify {{{1
() {
    local cgroup cgpath
    [[ -f /proc/self/cgroup ]] || return
    for cgroup in "${(@f)$(</proc/self/cgroup)}"; do
        cgpath=/sys/fs/cgroup/${cgroup[(ws.:.)2]#name=}/shell/zsh-$$
        [[ -d ${cgpath:h} && ${cgroup[(ws.:.)3]} != /shell/* ]] || continue
        mkdir ${cgpath}
        echo $$ | tee ${cgpath}/cgroup.procs >/dev/null
        echo 1 | tee ${cgpath}/notify_on_release >/dev/null
    done
}

# zplug {{{1
ZPLUG_HOME=${ZDOTDIR}/zplug
ZPLUG_THREADS=8

if [[ -f ${ZPLUG_HOME}/zplug ]]; then
    source ${ZPLUG_HOME}/zplug
else
    curl --create-dirs -sfLo ${ZPLUG_HOME}/zplug https://git.io/zplug
    source ${ZPLUG_HOME}/zplug
    zplug update --self
fi

zplug "zplug/zplug"
zplug "zsh-users/zaw"
zplug "zsh-users/zsh-completions"
zplug "zsh-users/zsh-history-substring-search"
zplug "zsh-users/zsh-syntax-highlighting", nice:10
zplug "motemen/ghq", use:"zsh/", if:"(( ${+commands[ghq]} ))"
zplug "glidenote/hub-zsh-completion", if:"(( ${+commands[hub]} ))"

if ! zplug check --verbose; then
    echo -n "Install? [y/N]: "
    if read -q; then
        echo
        zplug install
    fi
fi
zplug load

# dircolors {{{1
if (( ${+commands[dircolors]} )); then
    if [[ -f ~/.dir_colors ]]; then
        eval "$(dircolors -b ~/.dir_colors)"
    elif [[ -f /etc/DIR_COLORS ]]; then
        eval "$(dircolors -b /etc/DIR_COLORS)"
    else
        eval "$(dircolors -b)"
    fi
fi

# autoload {{{1
autoload -Uz add-zsh-hook
autoload -Uz colors

# options {{{1
setopt rm_star_silent

# completion {{{1
autoload -Uz compinit && compinit -u

setopt no_beep
setopt complete_aliases
setopt complete_in_word
setopt glob_complete
setopt hist_expand

zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ${ZTMPDIR}
zstyle ':completion:*' menu select=2
zstyle ':completion:*' list-colors "${(@s.:.)LS_COLORS}"

zstyle ':completion:*:functions:*' ignored-patterns '_*'

zstyle ':completion:*:sudo:*' command-path \
    {/usr/local/go,/usr/local,/usr,,/opt}/{sbin,bin}(N-/)

# zle {{{1
bindkey -e

cd-ghq-repository() {
    local repository
    repository="$(ghq list -p | fzy)"
    [[ -z "${repository}" ]] && return
    BUFFER="cd ${repository}"
    CURSOR=${#BUFFER}
    zle accept-line
}

zle -N cd-ghq-repository
bindkey '^g^g' cd-ghq-repository

# aliases {{{1
alias ls='ls -F --color=auto --quoting-style=literal'
alias la='ls -aF --color=auto --quoting-style=literal'
alias lA='ls -AF --color=auto --quoting-style=literal'
alias ll='ls -AlF --color=auto --time-style=long-iso --quoting-style=literal'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias mvi='mv -i'
alias rmi='rm -i'
alias rr='rm -rf'
alias p='print -rl --'
alias reload='exec zsh'
alias args='() { print -rl -- "${(@qqqq)argv}" }'
(( ${+commands[hub]} )) && alias git='hub'

alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'
alias -g G='| egrep -i'
alias -g L='| less'
alias -g H='| head -n 20'
alias -g T='| tail -n 20'
alias -g S='| sort'
alias -g SU='| sort -u'
alias -g EG='|& egrep -i'
alias -g EL='|& less'
alias -g EH='|& head -n 20'
alias -g ET='|& tail -n 20'
alias -g ES='|& sort'
alias -g ESU='|& sort -u'
alias -g NO='1>/dev/null'
alias -g NE='2>/dev/null'
alias -g NUL='1>/dev/null 2>&1'
alias -g EO='2>&1'

# commands {{{1
autoload -Uz zmv
autoload -Uz zargs
autoload -Uz dot
autoload -Uz zcompileall

# expn {{{1
setopt extended_glob

# chdir {{{1
setopt auto_cd
setopt auto_pushd
setopt pushd_ignore_dups

base_path=( ${path} )

function chpwd-npm-bin() {
    path=( (../)#node_modules/.bin(N-/:A) ${base_path} )
}

function chpwd-ls() {
    lA
}

add-zsh-hook chpwd chpwd-npm-bin
add-zsh-hook chpwd chpwd-ls

# history {{{1
setopt hist_ignore_all_dups

# prompt {{{1
autoload -Uz git-info

function rprompt() {
    local _status=()

    git-info || { kill -s USR1 $$; exit 1 }

    if (( ${gitstate[head_detached]} )); then
        echo -n "%F{yellow}[${gitstate[head_name]}]%f"
    else
        echo -n "%F{green}[${gitstate[head_name]}]%f"
    fi

    if [[ -n ${gitstate[state]} ]]; then
        echo -n "%F{red}{${gitstate[state]}"
        if (( ${gitstate[total]:-0} > 1 )); then
            echo -n "(${gitstate[step]}/${gitstate[total]})"
        fi
        if (( ${+gitstate[target_name]} )); then
            echo -n " ${gitstate[target_name]}"
        fi
        echo -n "}%f"
    fi

    (( ${gitstate[ahead]} )) && _status+=("%F{yellow}↑${gitstate[ahead]}%f")
    (( ${gitstate[behind]} )) && _status+=("%F{yellow}↓${gitstate[behind]}%f")
    (( ${gitstate[unmerged]} )) && _status+=("%F{red}!${gitstate[unmerged]}%f")
    (( ${gitstate[staged]} )) && _status+=("%F{yellow}*${gitstate[staged]}%f")
    (( ${gitstate[unstaged]} )) && _status+=("%F{yellow}+${gitstate[unstaged]}%f")
    (( ${gitstate[untracked]} )) && _status+=("%F{yellow}.${gitstate[untracked]}%f")
    (( ${gitstate[stash]} )) && _status+=("%F{yellow}@${gitstate[stash]}%f")
    (( ${#_status} > 0 )) && echo -n "%F{yellow}(%f${(j. .)_status}%F{yellow})%f"

    kill -s USR1 $$
}

function async-prompt() {
    RPROMPT=""
    if [[ -n ${ASYNC_PROMPT_PID} ]]; then
        kill -s HUP ${ASYNC_PROMPT_PID} >/dev/null 2>&1
    fi
    rprompt > ${ZTMPDIR}/rprompt &!
    ASYNC_PROMPT_PID=$!
}

function TRAPUSR1() {
    ASYNC_PROMPT_PID=
    RPROMPT="$(<${ZTMPDIR}/rprompt)"
    [[ -n "$RPROMPT" ]] && zle && zle reset-prompt
}

add-zsh-hook precmd async-prompt

PROMPT="%F{green}%n%f %F{blue}%1~ %(!.#.$)%f "

# env variable {{{1
export LANG=ja_JP.UTF-8
export LC_TIME=en_US.UTF-8
export LC_MESSAGES=en_US.UTF-8
export LANGUAGE=en_US

export LESS="--no-init --quit-if-one-screen --RAW-CONTROL-CHARS"
export LESSHISTFILE=/dev/null
