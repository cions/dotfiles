#!/bin/zsh
# vim: foldmethod=marker

# preamble {{{1
autoload -Uz add-zsh-hook
zmodload zsh/complist
zmodload zsh/terminfo

DOTFILES=${${(%):-%x}:A:h:h}

# options {{{1
setopt no_beep
setopt combining_chars
setopt extended_glob
setopt no_flow_control
setopt hist_subst_pattern
setopt ignore_eof
setopt rc_quotes
setopt re_match_pcre
setopt rm_star_silent

# cgclassify {{{1
() {
    local cgroup cgpath
    if [[ ! -f /proc/self/cgroup ]] return
    for cgroup in "${(@f)$(</proc/self/cgroup)}"; {
        cgpath=/sys/fs/cgroup/${cgroup[(ws.:.)2]#name=}/shell/zsh-$$
        if ! [[ -d ${cgpath:h} && ${cgroup[(ws.:.)3]} != /shell/* ]] continue
        mkdir ${cgpath} 2>/dev/null || continue
        print $$ > ${cgpath}/cgroup.procs
        print 1 > ${cgpath}/notify_on_release
        if [[ -f ${cgpath}/freezer.state ]] {
            chgrp wheel ${cgpath}/freezer.state
            chmod g+w ${cgpath}/freezer.state
        }
        if [[ -f ${cgpath}/pids.max ]] {
            echo 1024 > ${cgpath}/pids.max
        }
    }
}

# zplug {{{1
ZPLUG_HOME=${ZDOTDIR}/zplug
ZPLUG_THREADS="$(nproc)"

if [[ ! -f ${ZPLUG_HOME}/init.zsh ]] {
    git clone https://github.com/zplug/zplug.git ${ZPLUG_HOME}
}

source ${ZPLUG_HOME}/init.zsh

zplug "zplug/zplug", hook-build:"zplug --self-manage"
zplug "mafredri/zsh-async"
zplug "zsh-users/zsh-syntax-highlighting", defer:2
if [[ -O ${DOTFILES} ]] {
    zplug "${DOTFILES}/zsh", from:"local"
} else {
    zplug "cions/dotfiles", use:"zsh/"
}

zplug check || zplug install

zplug load

# zcompile {{{1
() {
    local file
    for file in ${ZDOTDIR}/*.zwc(ND); {
        if [[ ${file:r} -nt ${file} ]] zcompile ${file:r}
    }
}

# dircolors {{{1
if (( ${+commands[dircolors]} )) {
    if [[ -f ~/.dir_colors ]] {
        eval "$(dircolors -b ~/.dir_colors)"
    } elif [[ -f /etc/DIR_COLORS ]] {
        eval "$(dircolors -b /etc/DIR_COLORS)"
    } else {
        eval "$(dircolors -b)"
    }
}

# commands {{{1
autoload -Uz zargs
autoload -Uz zmv

args() {
    print -rl -- "${(@q+)argv}"
}

mkcd() {
    mkdir -p -- $1 && cd -- $1
}

# aliases {{{1
alias ls=' ls -F --color=auto --quoting-style=literal'
alias la=' ls -aF --color=auto --quoting-style=literal'
alias lA=' ls -AF --color=auto --quoting-style=literal'
alias ll=' ls -AlF --color=auto --time-style=long-iso --quoting-style=literal'
alias grep='grep -E --color=auto'
alias rm='rm -I'
alias rr='rm -rI'
alias rrf='rm -rf'
alias p='print -rl --'
alias reload='exec zsh'
alias rename='noglob zmv -W'
alias dot='git -C ${DOTFILES}'
if (( ${+commands[hub]} )) alias git='hub'

alias -g G='| grep -E'
alias -g GV='| grep -E -v'
alias -g L='| less'
alias -g H='| head -n $((LINES-2))'
alias -g T='| tail -n $((LINES-2))'
alias -g S='| sort'
alias -g SU='| sort -u'
alias -g NO='1>/dev/null'
alias -g NE='2>/dev/null'
alias -g NUL='1>/dev/null 2>&1'
alias -g EO='2>&1'

# zle {{{1
autoload -Uz select-word-style
select-word-style bash

autoload -Uz edit-command-line
zle -N edit-command-line

autoload -Uz history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end

autoload -Uz select-bracketed
zle -N select-bracketed

autoload -Uz select-quoted
zle -N select-quoted

autoload -Uz surround
zle -N add-surround surround
zle -N change-surround surround
zle -N delete-surround surround

unalias -m run-help
autoload -Uz run-help run-help-{git,ip,openssl,sudo}
alias run-help=' man'

bindkey -v

bindkey -M viins '^@' zle-widget-cd-recent-dirs
bindkey -M viins '^A' beginning-of-line
bindkey -M viins '^B' backward-char
bindkey -M viins '^E' end-of-line
bindkey -M viins '^F' forward-char
bindkey -M viins '^G' zle-widget-cd-repository
bindkey -M viins '^K' kill-line
bindkey -M viins '^N' history-beginning-search-forward-end
bindkey -M viins '^P' history-beginning-search-backward-end
bindkey -M viins '^Q' push-line
bindkey -M viins '^R' zle-widget-insert-history
bindkey -M viins '^U' kill-whole-line
bindkey -M viins '^X^E' edit-command-line
bindkey -M viins '^X^H' expand-history
bindkey -M viins '^X^W' expand-word
bindkey -M viins '^[.' insert-last-word
bindkey -M viins '^[h' run-help
bindkey -M viins '^^' zle-widget-cd-parents

bindkey -M vicmd 'ys' add-surround
bindkey -M vicmd 'cs' change-surround
bindkey -M vicmd 'ds' delete-surround
bindkey -M visual 'S' add-surround

() {
    local m c
    for m in visual viopp; {
        for c in {a,i}${(s::)^:-'()[]{}<>bB'}; {
            bindkey -M $m $c select-bracketed
        }
        for c in {a,i}{\',\",\`}; {
            bindkey -M $m $c select-quoted
        }
    }
}

# completion {{{1
setopt always_to_end
setopt glob_complete
setopt magic_equal_subst

zstyle ':completion:*' cache-path ${ZDOTDIR}/cache
zstyle ':completion:*' completer \
    _expand _complete _match _prefix _list
zstyle ':completion:*' group-name ''
zstyle ':completion:*' list-colors "${(@s.:.)LS_COLORS}"
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' menu select
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' verbose yes

zstyle ':completion:*' format '%F{blue}%d%f'
zstyle ':completion:*:descriptions' format '%F{yellow}completing %B%d%b%f'
zstyle ':completion:*:messages' format '%F{yellow}%d%f'
zstyle ':completion:*:warnings' format '%F{red}No matches for: %F{yellow}%d%f'
zstyle ':completion:*:options' description yes

zstyle ':completion:*:functions:*' ignored-patterns '_*'
zstyle ':completion:*:manuals' separate-sections yes
zstyle ':completion:*:cd:*' ignore-parents parent pwd

zle -C complete-file menu-expand-or-complete _generic
zstyle ':completion:complete-file:*' completer _files
bindkey '^X^F' complete-file

bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect '^K' accept-and-infer-next-history

# chdir {{{1
setopt auto_cd

autoload -Uz chpwd_recent_dirs

add-zsh-hook -Uz chpwd chpwd_recent_dirs
add-zsh-hook -Uz chpwd chpwd-hook-direnv
add-zsh-hook -Uz chpwd chpwd-hook-ls

zstyle ':completion:*' recent-dirs-insert both
zstyle ':chpwd:*' recent-dirs-max 1000
zstyle ':chpwd:*' recent-dirs-default yes
zstyle ':chpwd:*' recent-dirs-file ${ZDOTDIR}/.recent-dirs-file
zstyle ':chpwd:*' recent-dirs-pushd yes

# history {{{1
HISTFILE=${ZDOTDIR}/.zsh_history
HISTSIZE=100000
SAVEHIST=100000

setopt extended_history
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_no_functions
setopt hist_no_store
setopt hist_reduce_blanks
setopt hist_verify
setopt share_history

# prompt {{{1
_powerprompt() {
    local _status=${status}
    local segments=()

    if (( _status != 0 )) segments+=( "red:${_status}" )
    if (( ${(%):-%j} != 0 )) segments+=( "orange:%j" )

    case ${KEYMAP} in
        (viins|main) segments+=( "cyan:INSERT" ) ;;
        (vicmd)      segments+=( "red:NORMAL" ) ;;
    esac

    if (( EUID == 0 )) {
        segments+=( "magenta:%n" )
    } else {
        segments+=( "green:%n" )
    }
    if (( ${+SSH_CONNECTION} )) segments+=( "yellow:%M" )
    segments+=( "gray3:%1~" )
    PROMPT="$(powerprompt -f zsh -L -- "${segments[@]}") "

    local width=${(%)#PROMPT}
    case ${KEYMAP} in
        (viins|main) segments=( "cyan:INSERT" ) ;;
        (vicmd)      segments=( "red:NORMAL" ) ;;
    esac
    segments+=( "gray3:%$((width-13))<<${(l:width-13:)}%1_%<<" )
    PROMPT2="$(powerprompt -f zsh -L -- "${segments[@]}") "

    zle reset-prompt
}

_plainprompt() {
    PROMPT='%F{green}%n%F{blue} %1~ %(!.#.$)%f '
    RPROMPT=""

    local width=${(%)#PROMPT}
    PROMPT2="%F{blue}%$((width-2))<<${(l:width-2:)}%1_%<<>%f "
}

_rprompt() {
    local workdir=${PWD}
    if [[ ${workdir} == ${HOME} ]] workdir=${DOTFILES}
    RPROMPT=""
    async_job rprompt_worker _rprompt-async ${workdir}
}

_rprompt-async() {
    local workdir=${argv[1]}
    local segments=()

    cd -q ${workdir} 2>/dev/null || return 1
    git-info || return 1

    if (( gitstate[head_detached] )) {
        segments+=( "yellow:${gitstate[head_name]}" )
    } else {
        segments+=( "green:${gitstate[head_name]}" )
    }

    if [[ -n ${gitstate[state]} ]] {
        local state="${gitstate[state]}"
        if (( gitstate[total] > 1 )) {
            state+=" (${gitstate[step]}/${gitstate[total]})"
        }
        segments+=( "orange:${state}" )
        if [[ -n ${gitstate[target_name]} ]] {
            segments+=( "orange:${gitstate[target_name]}" )
        }
    }

    local _status=()
    if (( gitstate[ahead]       )) _status+=( "${gitstate[ahead]}" )
    if (( gitstate[behind]      )) _status+=( "${gitstate[behind]}" )
    if (( gitstate[unmerged]    )) _status+=( "${gitstate[unmerged]}" )
    if (( gitstate[staged]      )) _status+=( "${gitstate[staged]}" )
    if (( gitstate[wt_modified] )) _status+=( "${gitstate[wt_modified]}" )
    if (( gitstate[wt_deleted]  )) _status+=( "${gitstate[wt_deleted]}" )
    if (( gitstate[untracked]   )) _status+=( "${gitstate[untracked]}" )
    if (( gitstate[stash]       )) _status+=( "${gitstate[stash]}" )
    if (( ${#_status} > 0 )) {
        segments+=( "yellow:${(j: :)_status}" )
    }

    powerprompt -f zsh -R -- "${segments[@]}"
    return 0
}

_rprompt-callback() {
    local returncode=${argv[2]}
    local stdout=${argv[3]}

    if (( returncode != 0 )) return
    RPROMPT=${stdout}
    zle reset-prompt
}

nopowerline() {
    zle -D zle-line-init zle-keymap-select 2>/dev/null
    async_stop_worker rprompt_worker
    add-zsh-hook -d precmd _rprompt

    add-zsh-hook -Uz precmd _plainprompt
}

if (( ${+commands[powerprompt]} )) {
    zle -N zle-line-init _powerprompt
    zle -N zle-keymap-select _powerprompt
    async_start_worker rprompt_worker -u
    async_register_callback rprompt_worker _rprompt-callback
    add-zsh-hook -Uz precmd _rprompt
} else {
    nopowerline
}

# gpg-agent {{{1
if (( ${+commands[gpgconf]} )) {
    unset SSH_AGENT_PID
    export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
    export GPG_TTY=${TTY}

    _gpg-agent-updatestartuptty() {
        ( gpg-connect-agent UPDATESTARTUPTTY /bye >/dev/null 2>&1 & )
    }
    add-zsh-hook -Uz preexec _gpg-agent-updatestartuptty
}

# env variable {{{1
export LANG=ja_JP.UTF-8
export LC_TIME=en_US.UTF-8
export LC_MESSAGES=en_US.UTF-8
export LANGUAGE=en_US

export LESS="--no-init --quit-if-one-screen --RAW-CONTROL-CHARS"
export LESSHISTFILE=/dev/null
