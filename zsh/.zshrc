#!/bin/zsh
# vim: set foldmethod=marker:

# preamble {{{1
autoload -Uz add-zsh-hook
zmodload zsh/complist
zmodload zsh/mapfile
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

# plugins {{{1
loadplugin() {
    if [[ ! -d ${ZDOTDIR}/.plugins/${argv[1]:t} ]]; then
        mkdir -p ${ZDOTDIR}/.plugins || return 1
        git clone --depth=1 https://github.com/${argv[1]}.git ${ZDOTDIR}/.plugins/${argv[1]:t} || return 1
    fi
    source ${ZDOTDIR}/.plugins/${argv[1]:t}/${argv[2]:-*.plugin.zsh}
}

loadplugin mafredri/zsh-async
loadplugin zdharma/fast-syntax-highlighting && fast-theme -q ${ZDOTDIR}/theme.ini
if [[ -O ${DOTFILES} ]]; then
    source ${DOTFILES}/zsh/init.zsh
else
    loadplugin cions/dotfiles zsh/init.zsh
fi

# commands {{{1
autoload -Uz zargs
autoload -Uz zmv

args() {
    print -rl -- "${(@q+)argv}"
}

mkcd() {
    mkdir -p -- $1 && cd -- $1
}

rr() {
    local ans
    print -r -- rm -rf ${argv}
    read -r 'ans?execute? '
    [[ ${ans} == (#i)(y|yes) ]] && command rm -rf ${argv}
}

bak() {
    local file
    for file; do
        mv -i ${file} ${file}.bak
    done
}

# aliases {{{1
if (( ${+commands[exa]} )); then
    alias ls='exa --classify --sort=Name'
    alias la='exa --classify --sort=Name --all'
    alias lA='exa --classify --sort=Name --all'
    alias lt='exa --classify --sort=Name --all --tree'
    alias ll='exa --classify --sort=Name --all --long --binary --group --time-style=long-iso'
    alias llt='exa --classify --sort=Name --all --long --tree --binary --group --time-style=long-iso'
elif (( ${+commands[dircolors]} )); then
    alias ls='ls -F --color=auto --quoting-style=literal'
    alias la='ls -AF --color=auto --quoting-style=literal'
    alias lA='ls -AF --color=auto --quoting-style=literal'
    alias ll='ls -AlF --color=auto --quoting-style=literal --time-style=long-iso'
else
    alias ls='ls -F'
    alias la='ls -AF'
    alias lA='ls -AF'
    alias ll='ls -AlF'
fi
(( ${+commands[bat]} )) && alias cat='bat'
alias grep='grep -E --color=auto'
alias rga="rg --hidden --glob='!.git/'"
alias p='print -rC1 --'
alias reload='exec zsh'
alias rename='noglob zmv -W'
alias run-help='man'
alias dot='git -C ${DOTFILES}'
alias gdiff='git diff --no-index'

alias -g G='| grep -E'
alias -g GV='| grep -E -v'
alias -g L='| less'
alias -g H='| head -n $((LINES-2))'
alias -g T='| tail -n $((LINES-2))'
alias -g S='| sort'
alias -g SU='| sort -u'
alias -g NO='1>/dev/null'
alias -g NE='2>/dev/null'
alias -g NUL='&>/dev/null'
alias -g EO='2>&1'

# completion {{{1
setopt always_to_end
setopt magic_equal_subst

if (( ${+functions[_completer]} )); then
    zstyle ':completion:*' completer _expand _completer:complete
else
    zstyle ':completion:*' completer _expand _complete
fi
zstyle ':completion:*' group-name ''
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-prompt '%F{black}%K{white}%l %p%f%k'
zstyle ':completion:*' matcher-list '' '+m:{a-z}={A-Z}' '+m:{A-Z}={a-z}'
zstyle ':completion:*' menu select
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' verbose yes

zstyle ':completion:*:*' format '%F{blue}%d%f'
zstyle ':completion:*:messages' format '%F{yellow}%B%d%b%f'
zstyle ':completion:*:warnings' format '%F{red}No matches for: %F{yellow}%d%f'

zstyle ':completion:*:manuals' separate-sections yes
zstyle ':completion:*:processes' command 'ps -e -o pid=,user=:10,comm='
zstyle ':completion:*:*:cd:*:*' ignore-parents parent pwd

zle -C expand menu-complete _generic
zstyle ':completion:expand:*' completer _expand
zstyle ':completion:expand:*' accept-exact yes

zle -C complete-file menu-complete _generic
zstyle ':completion:complete-file:*' completer _complete_file

autoload -Uz compinit && compinit -u

# zle {{{1
# autoload {{{2
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

# zstyles {{{2
zstyle ':zle:*' word-chars '!#$%&()*+-.<>?@[\]^_{}~'
zstyle ':zle:*' word-style standard

# key bindings {{{2
bindkey -v

if (( ${+functions[zle-repeating-dot]} )); then
    bindkey -M viins '.' zle-repeating-dot
fi
bindkey -M viins '^A' beginning-of-line
bindkey -M viins '^B' backward-char
bindkey -M viins '^D' list-choices
bindkey -M viins '^E' end-of-line
bindkey -M viins '^F' forward-char
bindkey -M viins '^G' zle-cd-repository
bindkey -M viins '^H' vi-backward-delete-char
bindkey -M viins '^I' menu-complete
bindkey -M viins '^J' accept-line
bindkey -M viins '^K' kill-line
bindkey -M viins '^L' clear-screen
bindkey -M viins '^M' accept-line
bindkey -M viins '^N' history-beginning-search-forward-end
bindkey -M viins '^O' zle-cd-recent-dirs
bindkey -M viins '^P' history-beginning-search-backward-end
bindkey -M viins '^Q' push-line-or-edit
bindkey -M viins '^R' zle-insert-history
bindkey -M viins '^S' send-break
# bindkey -M viins '^T' self-insert
bindkey -M viins '^U' kill-whole-line
bindkey -M viins '^V' vi-quoted-insert
bindkey -M viins '^W' zle-backward-kill-word
bindkey -M viins '^X^E' edit-command-line
bindkey -M viins '^X^F' complete-file
bindkey -M viins '^X^H' run-help
bindkey -M viins '^X^R' redo
bindkey -M viins '^X^U' undo
bindkey -M viins '^X^W' expand
bindkey -M viins '^X^X' _complete_help
# bindkey -M viins '^Y' self-insert
bindkey -M viins '^[.' insert-last-word
bindkey -M viins '^^' zle-cd-parents

bindkey -M vicmd '^A' beginning-of-line
bindkey -M vicmd '^D' list-choices
bindkey -M vicmd '^E' end-of-line
bindkey -M vicmd '^G' zle-cd-repository
bindkey -M vicmd '^J' accept-line
bindkey -M vicmd '^L' clear-screen
bindkey -M vicmd '^M' accept-line
bindkey -M vicmd '^N' history-beginning-search-forward-end
bindkey -M vicmd '^O' zle-cd-recent-dirs
bindkey -M vicmd '^P' history-beginning-search-backward-end
bindkey -M vicmd '^Q' push-line-or-edit
bindkey -M vicmd '^X^E' edit-command-line
bindkey -M vicmd '^X^H' run-help
bindkey -M vicmd '^X^R' redo
bindkey -M vicmd '^X^U' undo
bindkey -M vicmd '^X^X' _complete_help
bindkey -M vicmd '^^' zle-cd-parents

bindkey -M vicmd 'sa' add-surround
bindkey -M vicmd 'sr' change-surround
bindkey -M vicmd 'sd' delete-surround
bindkey -M visual 'sa' add-surround

() {
    local m c
    for m in visual viopp; do
        for c in {a,i}${(s::)^:-'()[]{}<>bB'}; do
            bindkey -M $m $c select-bracketed
        done
        for c in {a,i}{\',\",\`}; do
            bindkey -M $m $c select-quoted
        done
    done
}

bindkey -M menuselect '^B' vi-backward-char
bindkey -M menuselect '^F' vi-forward-char
bindkey -M menuselect '^H' accept-and-hold
bindkey -M menuselect '^K' accept-and-infer-next-history
bindkey -M menuselect '^N' menu-complete
bindkey -M menuselect '^P' reverse-menu-complete
bindkey -M menuselect '^R' history-incremental-search-forward
bindkey -M menuselect '^[[Z' reverse-menu-complete
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char

# zle hooks {{{2
zle-line-init() {
    local _status=${status}

    if [[ ${CONTEXT} == start && -z ${BUFFER} && -n ${ZLE_LINE_ABORTED}
            && ${ZLE_LINE_ABORTED} != ${history[$((HISTCMD-1))]} ]]; then
        BUFFER=${ZLE_LINE_ABORTED}
        CURSOR=${#BUFFER}
        zle split-undo
        BUFFER=""
        CURSOR=0
        unset ZLE_LINE_ABORTED
    fi

    ${_PROMPT_FUNCTION:-:} ${_status}
}
zle -N zle-line-init

zle-line-finish() {
    ZLE_LINE_ABORTED="${PREBUFFER}${BUFFER}"
}
zle -N zle-line-finish

zle-keymap-select() {
    ${_PROMPT_FUNCTION:-:} ${status}
}
zle -N zle-keymap-select

# chdir {{{1
autoload -Uz chpwd_recent_dirs
add-zsh-hook -Uz chpwd chpwd_recent_dirs

add-zsh-hook -Uz chpwd chpwd-hook-direnv
add-zsh-hook -Uz chpwd chpwd-hook-ls

zstyle ':completion:*' recent-dirs-insert both
zstyle ':chpwd:*' recent-dirs-max 1000
zstyle ':chpwd:*' recent-dirs-default yes
zstyle ':chpwd:*' recent-dirs-file ${ZDOTDIR}/.recent-dirs
zstyle ':chpwd:*' recent-dirs-pushd yes

# history {{{1
add-zsh-hook -Uz zshaddhistory ignore-history

HISTFILE=${ZDOTDIR}/.zsh_history
HISTSIZE=100000
SAVEHIST=100000

setopt extended_history
setopt hist_ignore_all_dups
setopt no_hist_ignore_space
setopt hist_no_store
setopt no_hist_reduce_blanks
setopt hist_verify
setopt share_history

# prompt {{{1
(( ENABLE_ICONS )) && prompt default || prompt simple

# zrecompile {{{1
() {
    local targets file

    targets=(
        ${ZDOTDIR}/.zprofile
        ${ZDOTDIR}/.zshenv
        ${ZDOTDIR}/.zshrc
    )
    for file in ${targets}; do
        if [[ ! -f ${file}.zwc || ${file} -nt ${file}.zwc ]]; then
            zcompile ${file}
        fi
    done
}

# gpg-agent {{{1
if (( ${+commands[gpgconf]} )); then
    unset SSH_AGENT_PID
    export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
    export GPG_TTY=${TTY}

    _gpg-agent-updatestartuptty() {
        ( gpg-connect-agent updatestartuptty /bye >/dev/null 2>&1 & )
    }
    add-zsh-hook -Uz preexec _gpg-agent-updatestartuptty
fi

# dircolors {{{1
if (( ${+commands[dircolors]} )); then
    if [[ -f ~/.dircolors ]]; then
        eval "$(dircolors -b ~/.dircolors)"
    elif [[ -f /etc/DIR_COLORS ]]; then
        eval "$(dircolors -b /etc/DIR_COLORS)"
    else
        eval "$(dircolors -b)"
    fi
fi

# environment variables {{{1
export LANG=ja_JP.UTF-8
export LC_TIME=en_US.UTF-8
export LC_MESSAGES=en_US.UTF-8
export LANGUAGE=en_US

export EDITOR=vim
export VISUAL=vim
export PAGER=less

export LESS="-FMRSgi -j.5 -z-4"
export LESSHISTFILE="-"

export JQ_COLORS="2;39:0;31:0;31:0;36:0;32:1;39:1;39"

export GOPATH=${HOME}/.cache/go
export GOBIN=${HOME}/.bin
