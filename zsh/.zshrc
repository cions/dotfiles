#!/bin/zsh
# vim: foldmethod=marker

# preamble {{{1
autoload -Uz add-zsh-hook
zmodload zsh/complist
zmodload zsh/parameter
zmodload zsh/terminfo
zmodload zsh/zutil

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
        [[ -f ${cgpath}/freezer.state ]] && {
            chgrp wheel ${cgpath}/freezer.state
            chmod g+w ${cgpath}/freezer.state
        }
        [[ -f ${cgpath}/pids.max ]] && echo 1024 > ${cgpath}/pids.max
    done
}

# zplug {{{1
ZPLUG_HOME=${ZDOTDIR}/zplug
ZPLUG_THREADS="$(nproc)"

if [[ ! -f ${ZPLUG_HOME}/init.zsh ]]; then
    git clone https://github.com/zplug/zplug.git ${ZPLUG_HOME}
fi

source ${ZPLUG_HOME}/init.zsh

zplug "zplug/zplug"
zplug "mafredri/zsh-async"
zplug "zsh-users/zsh-syntax-highlighting", defer:2
if [[ -O ${DOTFILES} ]]; then
    zplug "${DOTFILES}/zsh", from:"local"
else
    zplug "cions/dotfiles", use:"zsh/"
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

# commands {{{1
autoload -Uz zargs
autoload -Uz zmv

args() {
    print -rl -- "${(@qqqq)argv}"
}

zrecompile() {
    local file
    for file in ${ZDOTDIR}/**/*.zwc(ND); do
        [[ ${file:r} -nt ${file} ]] || continue
        zcompile ${file:r}
    done
}

# aliases {{{1
alias ls='ls -F --color=auto --quoting-style=literal'
alias la='ls -aF --color=auto --quoting-style=literal'
alias lA='ls -AF --color=auto --quoting-style=literal'
alias ll='ls -AlF --color=auto --time-style=long-iso --quoting-style=literal'
alias grep='grep -E --color=auto'
alias rm='rm -I'
alias rr='rm -rI'
alias rrf='rm -rf'
alias p='print -rl --'
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

# zle {{{1
bindkey -e

autoload -Uz history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^P" history-beginning-search-backward-end
bindkey "^N" history-beginning-search-forward-end

bindkey "^G^G" zle-widget-cd-repository

# completion {{{1
setopt no_beep
setopt complete_aliases
setopt complete_in_word
setopt glob_complete
setopt hist_expand

zstyle ':completion:*' cache-path ${ZDOTDIR}/cache
zstyle ':completion:*' completer \
    _expand _complete _match _prefix _files _list _history
zstyle ':completion:*' group-name ''
zstyle ':completion:*' list-colors "${(@s.:.)LS_COLORS}"
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' menu select
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' verbose yes

zstyle ':completion:*' format '%F{blue}%d%f'
zstyle ':completion:messages' format '%F{yellow}%d%f'
zstyle ':completion:warnings' format '%F{red}No matches for: %F{yellow}%d%f'
zstyle ':completion:descriptions' format '%F{yellow}completing %B%d%b%f'
zstyle ':completion:options' description yes

zstyle ':completion:*:functions:*' ignored-patterns '_*'

zle -C complete-file menu-expand-or-complete _generic
zstyle ':completion:complete-file:*' completer _files
bindkey '^X^F' complete-file

bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'j' down-line-or-history
bindkey -M menuselect 'k' up-line-or-history
bindkey -M menuselect 'l' vi-forward-char

# chdir {{{1
setopt auto_cd
setopt auto_pushd
setopt pushd_ignore_dups

add-zsh-hook -Uz chpwd _chpwd-hook-direnv
add-zsh-hook -Uz chpwd _chpwd-hook-ls

# history {{{1
setopt hist_ignore_all_dups

# prompt {{{1
_plain_prompt="%F{green}%n%F{blue} %1~ %(!.#.$)%f "

_precmd_hook_prompt() {
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
    PROMPT="$(powerprompt -f zsh -L -- "${segments[@]}") "

    local width segment
    width=${(%)#PROMPT}
    print -v segment -f "%%%d<<%*s%%<<" $((width-4)) ${width} "%1_"
    PROMPT2="$(powerprompt -f zsh -L -- "gray3:${segment}") "
}

_rprompt_async() {
    local workdir=${argv[1]}
    local segments=()

    cd -q ${workdir} 2>/dev/null || return 1
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
    (( gitstate[wt_modified] )) && _status+=( "${gitstate[wt_modified]}" )
    (( gitstate[wt_deleted] )) && _status+=( "${gitstate[wt_deleted]}" )
    (( gitstate[untracked] )) && _status+=( "${gitstate[untracked]}" )
    (( gitstate[stash] )) && _status+=( "${gitstate[stash]}" )
    if (( ${#_status} > 0 )); then
        segments+=( "yellow:${(j: :)_status}" )
    fi

    powerprompt -f zsh -R -- "${segments[@]}"
    return 0
}

_precmd_hook_rprompt() {
    local workdir=${PWD}
    [[ ${workdir} == ${HOME} ]] && workdir=${DOTFILES}
    async_job rprompt_worker _rprompt_async ${workdir}
}

_rprompt_callback() {
    local returncode=${argv[2]}
    local stdout=${argv[3]}

    (( returncode != 0 )) && return
    RPROMPT=${stdout}
    [[ -n ${RPROMPT} ]] && zle && zle reset-prompt
}

_aligned_prompt2() {
    local width=${(%)#PROMPT}
    print -v PROMPT2 -f "%%F{blue}%%%d<<%*s%%<<>%%f"  \
        $((width-2)) ${width} "%1_"
}

nopowerline() {
    async_stop_worker rprompt_worker
    add-zsh-hook -d precmd _precmd_hook_prompt
    add-zsh-hook -d precmd _precmd_hook_rprompt

    PROMPT=${_plain_prompt}
    RPROMPT=""
    add-zsh-hook -Uz precmd _aligned_prompt2
}

if (( ${+commands[powerprompt]} )); then
    async_start_worker rprompt_worker -u -n
    async_register_callback rprompt_worker _rprompt_callback
    add-zsh-hook -Uz precmd _precmd_hook_prompt
    add-zsh-hook -Uz precmd _precmd_hook_rprompt
else
    nopowerline
fi

# gpg-agent {{{1
if (( ${+commands[gpg-connect-agent]} )); then
    _preexec-hook-gpg-agent() {
        gpg-connect-agent updatestartuptty /bye >/dev/null 2>&1
    }
    add-zsh-hook -Uz preexec _preexec-hook-gpg-agent
fi

# env variable {{{1
export LANG=ja_JP.UTF-8
export LC_TIME=en_US.UTF-8
export LC_MESSAGES=en_US.UTF-8
export LANGUAGE=en_US

export LESS="--no-init --quit-if-one-screen --RAW-CONTROL-CHARS"
export LESSHISTFILE=/dev/null
