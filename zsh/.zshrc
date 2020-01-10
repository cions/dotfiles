#!/bin/zsh
# vim: set foldmethod=marker:

# preamble {{{1
autoload -Uz add-zsh-hook
zmodload zsh/complist
zmodload zsh/mapfile
zmodload zsh/terminfo

export DOTFILES=${${(%):-%x}:A:h:h}

# zrecompile {{{1
() {
    local targets file

    targets=(
        ${ZDOTDIR}/.zprofile
        ${ZDOTDIR}/.zshenv
        ${ZDOTDIR}/.zshrc
    )
    for file in ${targets}; {
        if [[ ! -f ${file}.zwc || ${file} -nt ${file}.zwc ]] {
            zcompile ${file}
        }
    }
}

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

# zplug {{{1
ZPLUG_HOME=${ZDOTDIR}/zplug
ZPLUG_THREADS="$(nproc)"

if [[ ! -f ${ZPLUG_HOME}/init.zsh ]] && (( ${+commands[git]} )) {
    git clone https://github.com/zplug/zplug.git ${ZPLUG_HOME}
}

if [[ -f ${ZPLUG_HOME}/init.zsh ]] && zmodload -s zsh/pcre; then
    source ${ZPLUG_HOME}/init.zsh

    zplug "zplug/zplug", hook-build:'zplug --self-manage'
    zplug "mafredri/zsh-async"
    zplug "zdharma/fast-syntax-highlighting", defer:2, \
        hook-load:'fast-theme -q ${ZDOTDIR}/theme.ini'
    if [[ -O ${DOTFILES} ]] {
        zplug "${DOTFILES}/zsh", from:"local"
    } else {
        zplug "cions/dotfiles", use:"zsh/"
    }

    zplug check || zplug install
    zplug load
else
    source ${DOTFILES}/zsh/init.zsh
    autoload -Uz compinit && compinit -u
fi

# dircolors {{{1
if (( ${+commands[dircolors]} )) {
    if [[ -f ~/.dircolors ]] {
        eval "$(dircolors -b ~/.dircolors)"
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

rr() {
    local ans
    print -r -- rm -rf ${argv}
    read -r 'ans?execute? '
    [[ ${ans} == (#i)(y|yes) ]] && command rm -rf ${argv}
}

bak() {
    local file
    for file; {
        mv -i ${file} ${file}.bak
    }
}

# aliases {{{1
if (( ${+commands[dircolors]} )) {
    alias ls=' ls -F --color=auto --quoting-style=literal'
    alias la=' ls -aF --color=auto --quoting-style=literal'
    alias lA=' ls -AF --color=auto --quoting-style=literal'
    alias ll=' ls -AlF --color=auto --quoting-style=literal --time-style=long-iso'
} else {
    alias ls=' ls -F'
    alias la=' ls -aF'
    alias lA=' ls -AF'
    alias ll=' ls -AlF'
}
if grep -q --color=auto '^' <<< '' &>/dev/null; then
    alias grep='grep -E --color=auto'
else
    alias grep='grep -E'
fi
alias p='print -rl --'
alias reload='exec zsh'
alias rename='noglob zmv -W'
alias run-help=' man'
alias dot='git -C ${DOTFILES}'

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

if (( ${+functions[_completer]} )) {
    zstyle ':completion:*' completer _expand _completer:complete
} else {
    zstyle ':completion:*' completer _expand _complete
}
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

if (( ${+functions[zle-repeating-dot]} )) {
    bindkey -M viins '.' zle-repeating-dot
}
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
    for m in visual viopp; {
        for c in {a,i}${(s::)^:-'()[]{}<>bB'}; {
            bindkey -M $m $c select-bracketed
        }
        for c in {a,i}{\',\",\`}; {
            bindkey -M $m $c select-quoted
        }
    }
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
            && ${ZLE_LINE_ABORTED} != ${history[$((HISTCMD-1))]} ]] {
        BUFFER=${ZLE_LINE_ABORTED}
        CURSOR=${#BUFFER}
        zle split-undo
        BUFFER=""
        CURSOR=0
        unset ZLE_LINE_ABORTED
    }

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
(( ENABLE_ICONS )) && prompt default || prompt simple

# gpg-agent {{{1
if (( ${+commands[gpgconf]} )) {
    unset SSH_AGENT_PID
    export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
    export GPG_TTY=${TTY}

    _gpg-agent-updatestartuptty() {
        ( gpg-connect-agent updatestartuptty /bye >/dev/null 2>&1 & )
    }
    add-zsh-hook -Uz preexec _gpg-agent-updatestartuptty
}

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

export GOPATH=${HOME}/.cache/go
export GOBIN=${HOME}/.bin
