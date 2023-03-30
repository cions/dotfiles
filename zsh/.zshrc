#!/bin/zsh

# preamble
autoload -Uz add-zsh-hook
zmodload zsh/complist
zmodload zsh/datetime
zmodload zsh/mapfile
zmodload zsh/parameter
zmodload zsh/terminfo

DOTFILES=${${(%):-%x}:A:h:h}

# options
setopt no_beep
setopt combining_chars
setopt extended_glob
setopt no_flow_control
setopt hist_subst_pattern
setopt ignore_eof
setopt rc_quotes
setopt rematch_pcre
setopt rm_star_silent

# plugins
loadplugin() {
    if [[ ! -d ${ZDOTDIR}/.plugins/${argv[1]:t} ]]; then
        mkdir -p ${ZDOTDIR}/.plugins || return 1
        git clone --depth=1 https://github.com/${argv[1]}.git ${ZDOTDIR}/.plugins/${argv[1]:t} || return 1
    fi
    source ${ZDOTDIR}/.plugins/${argv[1]:t}/${argv[2]:-*.plugin.zsh}
}

zupdate() {
    local repo
    for repo in ${ZDOTDIR}/.plugins/*; do
        git -C ${repo} fetch --depth=1 && git -C ${repo} reset --merge FETCH_HEAD
    done
}

loadplugin mafredri/zsh-async
loadplugin zdharma-continuum/fast-syntax-highlighting && fast-theme -q ${ZDOTDIR}/theme.ini
if [[ -O ${DOTFILES} ]]; then
    source ${DOTFILES}/zsh/init.zsh
else
    loadplugin cions/dotfiles zsh/init.zsh
fi

# commands
autoload -Uz zargs
autoload -Uz zmv

args() {
    print -rl -- "${(@q+)argv}"
}

mkcd() {
    mkdir -p -- $1 && cd -- $1
}

rr() {
    local trashdir target
    if [[ -w /var/trash ]]; then
        trashdir=/var/trash
    else
        trashdir=${HOME}/.trash
        mkdir -p -- ${trashdir} || return 1
    fi
    for target in ${argv}; do
        [[ -e ${target} || -L ${target} ]] || continue
        if [[ "$(stat -f -c "%T" ${target} 2>/dev/null)" == "tmpfs" ]]; then
            command rm -r -- ${target}
            continue
        fi
        if [[ "$(stat -c "%D" ${target})" != "$(stat -c "%D" ${trashdir})" ]]; then
            print -u2 "zsh: error: ${target} is not on the same filesystem as ${trashdir}. skipped."
            continue
        fi
        mv -n -- ${target} "${trashdir}/${EPOCHSECONDS}-$(stat -c "%i" ${target})-${target:t}"
    done
}

bak() {
    local target
    for target in ${argv}; do
        mv -i -- ${target} ${target}.bak
    done
}

unbak() {
    local target
    for target in ${(M)argv:#*.bak}; do
        mv -i -- ${target} ${target%.bak}
    done
}

deno() {
    local -x DENO_DIR="${HOME}/.deno/cache"
    command deno "$@"
}

jq() {
    local -x JQ_COLORS="2;39:0;31:0;31:0;36:0;32:1;39:1;39"
    command jq "$@"
}

# aliases
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
if (( ${+commands[dircolors]} )); then
    alias grep='grep -E --color=auto'
else
    alias grep='grep -E'
fi
if (( ${+commands[bat]} )); then
    alias cat='bat'
fi
alias rm='print -u2 "zsh: error: rm command is disabled. use \`rr\` or \`command rm \` instead."; false'
alias rga="rg --hidden --glob='!.git/'"
alias p='print -rC1 --'
alias reload='exec zsh'
alias rename='noglob zmv -W'
alias run-help='man'
alias dot='git -C ${DOTFILES}'
alias gdiff='git diff --no-index'

alias -g G='| grep -E'
alias -g L='| less'
alias -g H='| head -n $((LINES-2))'
alias -g T='| tail -n $((LINES-2))'
alias -g S='| sort'
alias -g SU='| sort -u'
alias -g NO='1>/dev/null'
alias -g NE='2>/dev/null'
alias -g NUL='&>/dev/null'
alias -g EO='2>&1'

# completion
setopt always_to_end
setopt magic_equal_subst

if (( ${+functions[_completer]} )); then
    zstyle ':completion:*' completer _expand _completer:complete
else
    zstyle ':completion:*' completer _expand _complete
fi
zstyle ':completion:*' group-name ''
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

# zle
autoload -Uz edit-command-line
zle -N edit-command-line

autoload -Uz history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end

zstyle ':zle:*' word-chars '!#$%&()*+-.<>?@[\]^_{}~'
zstyle ':zle:*' word-style standard

bindkey -N main
bindkey -R -M main "^@"-"\M-^?" self-insert
bindkey -M main "^@" zle-toggle-leading-space
bindkey -M main "^A" beginning-of-line
bindkey -M main "^B" backward-char
bindkey -M main "^D" list-choices
bindkey -M main "^E" end-of-line
bindkey -M main "^F" forward-char
bindkey -M main "^G" zle-cd-repository
bindkey -M main "^H" backward-delete-char
bindkey -M main "^I" menu-complete
bindkey -M main "^J" accept-line
bindkey -M main "^K" kill-line
bindkey -M main "^L" clear-screen
bindkey -M main "^M" accept-line
bindkey -M main "^N" history-beginning-search-forward-end
bindkey -M main "^O" zle-cd-recent-dirs
bindkey -M main "^P" history-beginning-search-backward-end
bindkey -M main "^Q" push-line-or-edit
bindkey -M main "^R" zle-insert-history
bindkey -M main "^U" kill-whole-line
bindkey -M main "^V" quoted-insert
bindkey -M main "^W" zle-backward-kill-word
bindkey -M main "^X^B" vi-match-bracket
bindkey -M main "^X^E" edit-command-line
bindkey -M main "^X^F" complete-file
bindkey -M main "^X^H" run-help
bindkey -M main "^X^R" redo
bindkey -M main "^X^U" undo
bindkey -M main "^X^W" expand
bindkey -M main "^X^X" _complete_help
bindkey -M main "^[." insert-last-word
bindkey -M main "^[[200~" bracketed-paste
bindkey -M main "^[[A" up-line-or-history
bindkey -M main "^[[B" down-line-or-history
bindkey -M main "^[[C" forward-char
bindkey -M main "^[[D" backward-char
bindkey -M main "^[b" backward-word
bindkey -M main "^[d" kill-word
bindkey -M main "^[f" forward-word
bindkey -M main '^^' zle-cd-parents
bindkey -M main "^?" backward-delete-char
if (( ${+functions[zle-repeating-dot]} )); then
    bindkey -M main "." zle-repeating-dot
fi

bindkey -M menuselect "^B" backward-char
bindkey -M menuselect "^F" forward-char
bindkey -M menuselect "^H" accept-and-hold
bindkey -M menuselect "^I" complete-word
bindkey -M menuselect "^J" accept-line
bindkey -M menuselect "^K" accept-and-infer-next-history
bindkey -M menuselect "^M" accept-line
bindkey -M menuselect "^N" menu-complete
bindkey -M menuselect "^P" reverse-menu-complete
bindkey -M menuselect "^R" history-incremental-search-forward
bindkey -M menuselect "^[[A" up-line-or-history
bindkey -M menuselect "^[[B" down-line-or-history
bindkey -M menuselect "^[[C" forward-char
bindkey -M menuselect "^[[D" backward-char
bindkey -M menuselect "^[[Z" reverse-menu-complete
bindkey -M menuselect "h" backward-char
bindkey -M menuselect "j" down-line-or-history
bindkey -M menuselect "k" up-line-or-history
bindkey -M menuselect "l" forward-char

zle-line-init() {
    if [[ ${CONTEXT} == start
            && -z ${BUFFER}
            && -n ${ZLE_LINE_ABORTED}
            && ${ZLE_LINE_ABORTED} != ${history[$((HISTCMD-1))]} ]]; then
        BUFFER=${ZLE_LINE_ABORTED}
        CURSOR=${#BUFFER}
        zle split-undo
        BUFFER=""
        CURSOR=0
        unset ZLE_LINE_ABORTED
    fi
}
zle -N zle-line-init

zle-line-finish() {
    ZLE_LINE_ABORTED="${PREBUFFER}${BUFFER}"
}
zle -N zle-line-finish

# chdir
autoload -Uz chpwd_recent_dirs
add-zsh-hook -Uz chpwd chpwd_recent_dirs

add-zsh-hook -Uz chpwd chpwd-hook-direnv
add-zsh-hook -Uz chpwd chpwd-hook-ls

zstyle ':completion:*' recent-dirs-insert both
zstyle ':chpwd:*' recent-dirs-max 1000
zstyle ':chpwd:*' recent-dirs-default yes
zstyle ':chpwd:*' recent-dirs-file ${ZDOTDIR}/.recent-dirs
zstyle ':chpwd:*' recent-dirs-pushd yes

# history
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

# prompt
if [[ -v SSH_CONNECTION ]]; then
    psvar[1]="${(%):-%m}"
fi
if (( terminfo[colors] >= 256 )); then
    PROMPT="%b%F{235}%(?::%K{203} %? )%1(j:%K{216} %j :)%(!:%K{207}:%K{156}) %n %1(V:%K{227} %1v :)%F{255}%K{245} %1~ %f%k%b"$'\u00A0'
    PLAINPROMPT="%(?:: %? )%1(j: %j :) %n %1(V: %1v :) %1~  "
    PROMPT2="%b%F{255}%K{245} %1_ %f%k%b "

    update-prompt2() {
        local expanded="${(%)PLAINPROMPT}"
        local width="${#expanded}"
        PROMPT2="%F{255}%K{245} %$((width-3))<<${(l:width:)}%1_%<< %f%k "
    }
    add-zsh-hook -Uz precmd update-prompt2
else
    PROMPT="%b%(?::%F{red}(%?%) )%(!:%F{magenta}:%F{green})%n%1(V:%F{yellow}@%1v:)%F{blue} %1~ %(!:#:$)%f%k%b"$'\u00A0'
    PROMPT2="%b%F{blue}%1_>%f%k%b "
fi

update-rprompt() {
    local workdir=${PWD}
    [[ ${workdir} == ${HOME} ]] && workdir=${DOTFILES}
    RPROMPT=""
    async_job rprompt_worker rprompt-async ${workdir} 2>/dev/null || {
        async_start_worker rprompt_worker -u
        async_register_callback rprompt_worker rprompt-callback
        async_job rprompt_worker rprompt-async ${workdir}
    }
}

rprompt-async() {
    local workdir=${argv[1]}

    cd -q ${workdir} 2>/dev/null || return 1
    git-info || return 1

    if (( gitstate[head_detached] )); then
        print -n "%F{235}%K{227} ${gitstate[head_name]} "
    else
        print -n "%F{235}%K{156} ${gitstate[head_name]} "
    fi

    if [[ -n ${gitstate[state]} ]]; then
        print -n "%K{216} ${gitstate[state]} "
        if (( gitstate[total] > 1 )); then
            print -n "(${gitstate[step]}/${gitstate[total]}) "
        fi
        if [[ -n ${gitstate[target_name]} ]]; then
            print -n "\u2502 ${gitstate[target_name]} "
        fi
    fi

    local gitstatus=()
    (( gitstate[ahead]       )) && gitstatus+=( "⬆${gitstate[ahead]}" )
    (( gitstate[behind]      )) && gitstatus+=( "⬇${gitstate[behind]}" )
    (( gitstate[unmerged]    )) && gitstatus+=( "⚠${gitstate[unmerged]}" )
    (( gitstate[staged]      )) && gitstatus+=( "●${gitstate[staged]}" )
    (( gitstate[wt_modified] )) && gitstatus+=( "⊕${gitstate[wt_modified]}" )
    (( gitstate[wt_deleted]  )) && gitstatus+=( "⊖${gitstate[wt_deleted]}" )
    (( gitstate[untracked]   )) && gitstatus+=( "＋${gitstate[untracked]}" )
    (( gitstate[stash]       )) && gitstatus+=( "➡${gitstate[stash]}" )
    if (( ${#gitstatus} > 0 )); then
        print -n "%K{227} ${(j: :)gitstatus} "
    fi

    return 0
}

rprompt-callback() {
    local returncode=${argv[2]}
    local stdout=${argv[3]}
    (( returncode != 0 )) && return ${returncode}
    RPROMPT=${stdout}
    zle reset-prompt
}

if (( terminfo[colors] >= 256 && ${+functions[async_start_worker]} )); then
    async_start_worker rprompt_worker -u
    async_register_callback rprompt_worker rprompt-callback
    add-zsh-hook -Uz precmd update-rprompt
fi

# zrecompile
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

# gpg-agent
if (( ${+commands[gpgconf]} )); then
    unset SSH_AGENT_PID
    export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
    export GPG_TTY=${TTY}

    gpg-agent-updatestartuptty() {
        ( gpg-connect-agent updatestartuptty /bye >/dev/null 2>&1 & )
    }
    add-zsh-hook -Uz preexec gpg-agent-updatestartuptty
fi

# dircolors
if (( ${+commands[dircolors]} )); then
    if [[ -f ~/.dircolors ]]; then
        eval "$(dircolors -b ~/.dircolors)"
    elif [[ -f /etc/DIR_COLORS ]]; then
        eval "$(dircolors -b /etc/DIR_COLORS)"
    else
        eval "$(dircolors -b)"
    fi
    zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
fi

# environment variables
export LANG="en_US.UTF-8"
export EDITOR="vim"
export VISUAL="vim"
export PAGER="less"

export LESS="-FMRSgi -j.5 -z-4"
export LESSHISTFILE="-"
