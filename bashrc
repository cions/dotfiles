#!/bin/bash

# preamble
DOTFILES="$(dirname -- "$(readlink -- "${BASH_SOURCE[0]:-"$0"}")")"

exists() {
    command -v -- "$1" >/dev/null 2>&1
}

# options
shopt -s checkwinsize
shopt -s dotglob
shopt -s no_empty_cmd_completion
shopt -s globstar
shopt -s lithist
shopt -s nullglob

HISTCONTROL="ignoreboth"
HISTSIZE=10000
unset HISTFILE

# commands
args() {
    printf "%s\n" "${@@Q}"
}

mkcd() {
    # shellcheck disable=SC2164
    mkdir -p -- "$1" && cd -- "$1"
}

rr() {
    local trashdir target
    if [[ -w /var/trash ]]; then
        trashdir="/var/trash"
    else
        trashdir="${HOME}/.trash"
        mkdir -p -- "${trashdir}" || return 1
    fi
    for target in "$@"; do
        [[ -e "${target}" || -L "${target}" ]] || continue
        if [[ "$(stat -f -c "%T" -- "${target}")" == "tmpfs" ]]; then
            command rm -r -- "${target}"
            continue
        fi
        if [[ "$(stat -c "%D" -- "${target}")" != "$(stat -c "%D" -- "${trashdir}")" ]]; then
            echo "bash: error: ${target} is not on the same filesystem as ${trashdir}. skipped." >&2
            continue
        fi
        mv -n -- "${target}" "${trashdir}/$(date "+%s")-$(stat -c "%i" -- "${target}")-$(basename -- "${target}")"
    done
}

bak() {
    local target
    for target in "$@"; do
        mv -i -- "${target}" "${target}.bak"
    done
}

unbak() {
    local target
    for target in "$@"; do
        [[ "${target}" == *.bak ]] || continue
        mv -i -- "${target}" "${target%.bak}"
    done
}

# aliases
if exists exa; then
    alias ls='exa --classify --sort=Name'
    alias la='exa --classify --sort=Name --all'
    alias lA='exa --classify --sort=Name --all'
    alias lt='exa --classify --sort=Name --all --tree'
    alias ll='exa --classify --sort=Name --all --long --binary --group --time-style=long-iso'
    alias llt='exa --classify --sort=Name --all --long --tree --binary --group --time-style=long-iso'
elif exists dircolors; then
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
if exists dircolors; then
    alias grep='grep -E --color=auto'
else
    alias grep='grep -E'
fi
if exists bat; then
    alias cat='bat'
fi
alias rm='echo "bash: error: rm command is disabled. use \`rr\` or \`command rm\` instead." >&2; false'
alias rga="rg --hidden --glob='!.git/'"
alias reload='exec bash'
alias dot='git -C "${DOTFILES}"'
alias gdiff='git diff --no-index'

# key bindings
bind C-F:menu-complete
bind C-B:menu-complete-backward

# PROMPT_COMMAND
PROMPT_COMMAND_HOOKS=()
prompt_command() {
    local status=$? hook
    for hook in "${PROMPT_COMMAND_HOOKS[@]}"; do
        ${hook} ${status}
    done
}
PROMPT_COMMAND=prompt_command

# prompt
if [[ -v SSH_CONNECTION ]]; then
    PS1='\[\e[0m\e[32m\]\u\[\e[33m\]@\H \[\e[34m\]\W \$\[\e[0m\]'$'\u00A0'
else
    PS1='\[\e[0m\e[32m\]\u \[\e[34m\]\W \$\[\e[0m\]'$'\u00A0'
fi

update-prompt() {
    local status=$1 njobs width
    local -A colors=(
        [default]='\[\e[0m\]'
        [red]='\[\e[38;5;235;48;5;203m\]'
        [orange]='\[\e[38;5;235;48;5;216m\]'
        [yellow]='\[\e[38;5;235;48;5;227m\]'
        [green]='\[\e[38;5;235;48;5;156m\]'
        [cyan]='\[\e[38;5;235;48;5;117m\]'
        [blue]='\[\e[38;5;235;48;5;111m\]'
        [purple]='\[\e[38;5;235;48;5;170m\]'
        [magenta]='\[\e[38;5;235;48;5;207m\]'
        [gray]='\[\e[38;5;255;48;5;245m\]'
    )

    PS1="${colors[default]}"

    if (( status != 0 )); then
        PS1+="${colors[red]} ${status} "
    fi

    njobs="$(jobs -p | wc -l)"
    if (( njobs != 0 )); then
        PS1+="${colors[orange]} ${njobs} "
    fi

    PS1+="${colors[magenta]}"' \s '

    if (( EUID == 0 )); then
        PS1+=$'\u2502 \u '
    else
        PS1+="${colors[green]}"' \u '
    fi

    if [[ -v SSH_CONNECTION ]]; then
        PS1+="${colors[yellow]}"' \H '
    fi

    PS1+="${colors[gray]}"' \W '"${colors[default]}"$'\u00A0'

    width="$(echo -n "${PS1@P}" | sed $'s/\x01[^\x02]*\x02//g' | wc -L)"
    printf -v PS2 "${colors[default]}${colors[gray]} %*s ${colors[default]} " $((width-3)) "..."
}
if [[ "$(tput colors 2>/dev/null)" -ge 256 ]]; then
    PROMPT_COMMAND_HOOKS+=( update-prompt )
fi

# gpg-agent
if exists gpgconf; then
    unset SSH_AGENT_PID
    SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
    GPG_TTY="$(tty)"
    export SSH_AUTH_SOCK GPG_TTY

    gpg-agent-updatestartuptty() {
        ( gpg-connect-agent updatestartuptty /bye >/dev/null 2>&1 & )
    }
    PROMPT_COMMAND_HOOKS+=( gpg-agent-updatestartuptty )
fi

# dircolors
if exists dircolors; then
    if [[ -f ~/.dircolors ]]; then
        eval "$(dircolors -b ~/.dircolors)"
    elif [[ -f /etc/DIR_COLORS ]]; then
        eval "$(dircolors -b /etc/DIR_COLORS)"
    else
        eval "$(dircolors -b)"
    fi
fi

# environment variables
export LANG="en_US.UTF-8"
export EDITOR="vim"
export VISUAL="vim"
export PAGER="less"

export LESS="-FMRSgi -j.5 -z-4"
export LESSHISTFILE="-"
export JQ_COLORS="2;39:0;31:0;31:0;36:0;32:1;39:1;39"
