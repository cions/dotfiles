#!/bin/zsh
# vim: foldmethod=marker

fpath=( ${ZDOTDIR}/functions(N-/) ${fpath} )

export DOTFILES=${${(%):-%x}:h:A:h}

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

if [[ ! -f ${ZPLUG_HOME}/init.zsh ]]; then
    git clone https://github.com/zplug/zplug.git ${ZPLUG_HOME}
fi

source ${ZPLUG_HOME}/init.zsh

zplug "zplug/zplug"
zplug "mafredri/zsh-async"
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
zstyle ':completion:*' cache-path ${ZDOTDIR}/cache
zstyle ':completion:*' menu select=2
zstyle ':completion:*' list-colors "${(@s.:.)LS_COLORS}"

zstyle ':completion:*:functions:*' ignored-patterns '_*'

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
autoload -Uz dot
autoload -Uz zargs
autoload -Uz zcompileall
autoload -Uz zmv

# expn {{{1
setopt extended_glob

# chdir {{{1
setopt auto_cd
setopt auto_pushd
setopt pushd_ignore_dups

_bpath=( ${path} )
_apath=()
_dpath=()

function pathadd() {
    _apath=( ${^argv}(N-/:A) ${_apath} )
    chpwd-path
}

function pathdel() {
    if (( $# > 0 )); then
        _apath=( ${_apath:|argv} )
    elif (( ${#_apath} == 0 )); then
        print -u2 pathdel: no additional path
        return 1
    else
        local p=$(print -rl -- ${_apath} | fzy)
        _apath=( ${_apath:#${arg}} )
    fi
}

compdef _pathdel pathdel
function _pathdel() {
    compadd -- ${_apath}
}

function chpwd-path() {
    _dpath=( (../)#node_modules/.bin(N-/[1]:A) )
    path=( ${_apath} ${_dpath} ${_bpath} )
}

function chpwd-ls() {
    (( ZSH_SUBSHELL == 0 )) && lA
}

add-zsh-hook chpwd chpwd-path
add-zsh-hook chpwd chpwd-ls

# history {{{1
setopt hist_ignore_all_dups

# prompt {{{1
autoload -Uz git-info

function rprompt() {
    local _status=()

    cd "$1"

    git-info || exit 1

    if (( gitstate[head_detached] )); then
        echo -n "%F{yellow}[${gitstate[head_name]}]%f"
    else
        echo -n "%F{green}[${gitstate[head_name]}]%f"
    fi

    if [[ -n ${gitstate[state]} ]]; then
        echo -n "%F{red}{${gitstate[state]}"
        if (( gitstate[total] > 1 )); then
            echo -n "(${gitstate[step]}/${gitstate[total]})"
        fi
        if (( ${+gitstate[target_name]} )); then
            echo -n " ${gitstate[target_name]}"
        fi
        echo -n "}%f"
    fi

    (( gitstate[ahead] )) && _status+=("%F{yellow}↑${gitstate[ahead]}%f")
    (( gitstate[behind] )) && _status+=("%F{yellow}↓${gitstate[behind]}%f")
    (( gitstate[unmerged] )) && _status+=("%F{red}!${gitstate[unmerged]}%f")
    (( gitstate[staged] )) && _status+=("%F{yellow}*${gitstate[staged]}%f")
    (( gitstate[unstaged] )) && _status+=("%F{yellow}+${gitstate[unstaged]}%f")
    (( gitstate[untracked] )) && _status+=("%F{yellow}.${gitstate[untracked]}%f")
    (( gitstate[stash] )) && _status+=("%F{yellow}@${gitstate[stash]}%f")
    (( ${#_status} > 0 )) && echo -n "%F{yellow}(%f${(j. .)_status}%F{yellow})%f"
}

function async_rprompt() {
    RPROMPT=""
    if [[ ${PWD} == ${HOME} ]]; then
        async_job rprompt_worker rprompt ${DOTDIR}
    else
        async_job rprompt_worker rprompt ${PWD}
    fi
}

function rprompt_callback() {
    (( $2 != 0 )) && return
    RPROMPT="$3"
    [[ -n "${RPROMPT}" ]] && zle && zle reset-prompt
}

async_start_worker rprompt_worker -u -n
async_register_callback rprompt_worker rprompt_callback

add-zsh-hook precmd async_rprompt

PROMPT="%F{green}%n%f %F{blue}%1~ %(!.#.$)%f "
RPROMPT=""

# env variable {{{1
export LANG=ja_JP.UTF-8
export LC_TIME=en_US.UTF-8
export LC_MESSAGES=en_US.UTF-8
export LANGUAGE=en_US

export LESS="--no-init --quit-if-one-screen --RAW-CONTROL-CHARS"
export LESSHISTFILE=/dev/null
