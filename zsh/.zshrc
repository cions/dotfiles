#!/bin/zsh
# vim: foldmethod=marker

export DOTFILES=${${(%):-%x}:A:h:h}

# cgclassify {{{1
() {
    local cgroup cgpath
    [[ -f /proc/self/cgroup ]] || return
    for cgroup in "${(@f)$(</proc/self/cgroup)}"; do
        cgpath=/sys/fs/cgroup/${cgroup[(ws.:.)2]#name=}/shell/zsh-$$
        [[ -d ${cgpath:h} && ${cgroup[(ws.:.)3]} != /shell/* ]] || continue
        mkdir -- ${cgpath} 2>/dev/null || continue
        print $$ > ${cgpath}/cgroup.procs
        print 1 > ${cgpath}/notify_on_release
        [[ -f ${cgpath}/freezer.state ]] \
            && chgrp wheel ${cgpath}/freezer.state \
            && chmod g+w ${cgpath}/freezer.state
        [[ -f ${cgpath}/pids.max ]] && echo 1024 > ${cgpath}/pids.max
    done
}

# zplug {{{1
ZPLUG_HOME=${ZDOTDIR}/zplug
ZPLUG_THREADS=$(nproc)

if [[ ! -f ${ZPLUG_HOME}/init.zsh ]]; then
    git clone https://github.com/zplug/zplug.git ${ZPLUG_HOME}
fi

source ${ZPLUG_HOME}/init.zsh

zplug "zplug/zplug"
zplug "mafredri/zsh-async"
zplug "zsh-users/zsh-completions"
zplug "zsh-users/zsh-history-substring-search"
zplug "zsh-users/zsh-syntax-highlighting", defer:2
zplug "cions/dotfiles", use:"zsh/functions/*", lazy:1
zplug "glidenote/hub-zsh-completion", if:"(( ${+commands[hub]} ))"

if ! zplug check --verbose; then
    print -n "Install? [y/N]: "
    if read -q; then
        print
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

# options {{{1
setopt extended_glob
setopt rm_star_silent

# autoloads {{{1
autoload -Uz add-zsh-hook
autoload -Uz git-info
autoload -Uz zargs
autoload -Uz zcompileall
autoload -Uz zmv

# completion {{{1
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

function cd-repository() {
    local rootdir=${HOME}/src
    local repostory="$(cd ${rootdir}; print -rl -- */*/*(N-/) | fzy)"
    [[ -z "${repostory}" ]] && return
    BUFFER="cd ${rootdir}/${repostory}"
    CURSOR=${#BUFFER}
    zle accept-line
}

zle -N cd-repository
bindkey '^g^g' cd-repository

# aliases {{{1
alias ls='ls -F --color=auto --quoting-style=literal'
alias la='ls -aF --color=auto --quoting-style=literal'
alias lA='ls -AF --color=auto --quoting-style=literal'
alias ll='ls -AlF --color=auto --time-style=long-iso --quoting-style=literal'
alias grep='grep -E --color=auto'
alias rmi='rm -i'
alias rr='rm -rf'
alias p='print -rl --'
alias args='() { print -rl -- "${(@qqqq)argv}" }'
alias reload='exec zsh'
alias dot='git -C ${DOTFILES}'
(( ${+commands[hub]} )) && alias git='hub'

alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'
alias -g G='| grep -E'
alias -g GV='| grep -E -v'
alias -g L='| less'
alias -g H='| head -n 20'
alias -g T='| tail -n 20'
alias -g S='| sort'
alias -g SU='| sort -u'
alias -g NO='1>/dev/null'
alias -g NE='2>/dev/null'
alias -g NUL='1>/dev/null 2>&1'
alias -g EO='2>&1'

# chdir {{{1
setopt auto_cd
setopt auto_pushd
setopt pushd_ignore_dups

function _chpwd_hook_direnv() {
    local env t

    for env in ${_direnv}; do
        unset ${env}
    done
    if (( ${+_direnv_path} )); then
        path=( ${path:|_direnv_path} )
    fi

    _direnv=()
    _direnv_path=()

    t=( (../)#node_modules/.bin(N-/:A) )
    if (( ${#t} > 0 )); then
        _direnv_path+=( ${t[1]} )
    fi

    t=( (../)#pyvenv.cfg(N-.:h:A) )
    if (( ${#t} > 0 )); then
        VIRTUAL_ENV="${t[1]}"
        _direnv+=( VIRTUAL_ENV )
        _direnv_path+=( ${t[1]}/bin )
    fi

    path=( ${_direnv_path} ${path} )
    hash -r
}
add-zsh-hook chpwd _chpwd_hook_direnv

function _chpwd_hook_ls() {
    (( ZSH_SUBSHELL == 0 )) && lA
}
add-zsh-hook chpwd _chpwd_hook_ls

# history {{{1
setopt hist_ignore_all_dups

# prompt {{{1
_plain_prompt="%F{green}%n%F{blue} %1~ %(!.#.$)%f "

function nopowerline() {
    async_stop_worker rprompt_worker
    add-zsh-hook -d precmd _precmd_hook_prompt
    add-zsh-hook -d precmd _precmd_hook_rprompt

    PROMPT=${_plain_prompt}
    RPROMPT=""
}

function _precmd_hook_prompt() {
    local _status=${status}
    local jobnum=${(%):-%j}
    local segments=()

    if (( _status != 0 )); then
        segments+=( "red:${_status}" )
    fi
    if (( jobnum != 0 )); then
        segments+=( "orange:${jobnum}" )
    fi
    if (( EUID == 0 )); then
        segments+=( "magenta:%n" )
    else
        segments+=( "green:%n" )
    fi
    if (( ${+SSH_CONNECTION} )); then
        segments+=( "yellow:%M" )
    fi
    segments+=( "gray3:%1~" )
    PROMPT="$(powerprompt -f zsh -L ${segments}) "
}

function _rprompt_async() {
    local workdir=${argv[1]}
    local segments=()

    cd -- ${workdir} || return 1

    git-info || return 1

    if (( gitstate[head_detached] )); then
        segments+=( "yellow:${gitstate[head_name]}" )
    else
        segments+=( "green:${gitstate[head_name]}" )
    fi

    if [[ -n ${gitstate[state]} ]]; then
        local steps=""
        if (( gitstate[total] > 1 )); then
            steps=" (${gitstate[step]}/${gitstate[total]})"
        fi
        segments+=( "orange:${gitstate[state]}${steps}" )
        if [[ -n ${gitstate[target_name]} ]]; then
            segments+=( "orange:${gitstate[target_name]}" )
        fi
    fi

    local _status=()
    (( gitstate[ahead] )) && _status+=( "${gitstate[ahead]}" )
    (( gitstate[behind] )) && _status+=( "${gitstate[behind]}" )
    (( gitstate[unmerged] )) && _status+=( "${gitstate[unmerged]}" )
    (( gitstate[staged] )) && _status+=( "${gitstate[staged]}" )
    (( gitstate[wt_modified] )) && _status+=( "${gitstate[unstaged]}" )
    (( gitstate[wt_deleted] )) && _status+=( "${gitstate[unstaged]}" )
    (( gitstate[untracked] )) && _status+=( "${gitstate[untracked]}" )
    (( gitstate[stash] )) && _status+=( "${gitstate[stash]}" )
    if (( ${#_status} > 0 )); then
        segments+=( "yellow:${(j: :)_status}" )
    fi

    powerprompt -f zsh -R ${powerprompt_opts} ${segments}
    return 0
}

function _precmd_hook_rprompt() {
    RPROMPT=""

    local workdir=${PWD}
    [[ ${workdir} == ${HOME} ]] && workdir=${DOTFILES}
    async_job rprompt_worker _rprompt_async ${workdir}
}

function _rprompt_callback() {
    local returncode=${argv[2]}
    local stdout=${argv[3]}

    (( returncode != 0 )) && return
    RPROMPT=${stdout}
    [[ -n ${RPROMPT} ]] && zle && zle reset-prompt
}

if (( ${+commands[powerprompt]} )); then
    async_start_worker rprompt_worker -u -n
    async_register_callback rprompt_worker _rprompt_callback
    add-zsh-hook -Uz precmd _precmd_hook_prompt
    add-zsh-hook -Uz precmd _precmd_hook_rprompt
else
    PROMPT=${_plain_prompt}
    RPROMPT=""
fi

# env variable {{{1
function gpg-agent-updatestartuptty() {
    if (( ${+commands[gpg-connect-agent]} )); then
        gpg-connect-agent updatestartuptty /bye &>/dev/null
    fi
}
add-zsh-hook preexec gpg-agent-updatestartuptty

# env variable {{{1
export LANG=ja_JP.UTF-8
export LC_TIME=en_US.UTF-8
export LC_MESSAGES=en_US.UTF-8
export LANGUAGE=en_US

export LESS="--no-init --quit-if-one-screen --RAW-CONTROL-CHARS"
export LESSHISTFILE=/dev/null
