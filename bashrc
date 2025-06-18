#!/bin/bash

# shellcheck disable=SC2034
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
HISTSIZE=100000
unset HISTFILE

# commands
args() {
	printf "%s\n" "${@@Q}"
}

mkcd() {
	# shellcheck disable=SC2164
	mkdir -p -- "$1" && cd -- "$1"
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

rm() {
	echo "bash: error: rm command is disabled. use \`rmv\` or \`remove\` instead." >&2
	return 1
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
if exists eza; then
	alias ls='eza --classify --no-quotes --sort=Name'
	alias la='eza --classify --no-quotes --sort=Name --all'
	alias lA='eza --classify --no-quotes --sort=Name --all'
	alias lt='eza --classify --no-quotes --sort=Name --all --tree'
	alias ll='eza --classify --no-quotes --sort=Name --all --long --binary --group --time-style=long-iso'
	alias llt='eza --classify --no-quotes --sort=Name --all --tree --long --binary --group --time-style=long-iso'
elif exists dircolors; then
	alias ls='ls --classify --color=auto --quoting-style=literal'
	alias la='ls --classify --color=auto --quoting-style=literal --almost-all'
	alias lA='ls --classify --color=auto --quoting-style=literal --almost-all'
	alias ll='ls --classify --color=auto --quoting-style=literal --almost-all --format=long --time-style=long-iso'
else
	alias ls='ls -F'
	alias la='ls -AF'
	alias lA='ls -AF'
	alias ll='ls -AFl'
fi
if exists dircolors; then
	alias grep='grep -E --color=auto'
else
	alias grep='grep -E'
fi
if exists bat; then
	alias cat='bat'
fi
if exists rg; then
	alias rga="rg --hidden --glob='!.git/'"
fi
if exists fend; then
	alias calc='fend'
else
	alias calc='bc -l'
fi
alias remove='command rm'
alias reload='exec -l "${BASH}"'

# key bindings
bind C-F:menu-complete
bind C-B:menu-complete-backward

# PROMPT_COMMAND
__PROMPT_COMMAND_FUNCS=()
__prompt_command() {
	local status=$?
	local func
	for func in "${__PROMPT_COMMAND_FUNCS[@]}"; do
		${func} ${status}
	done
}
PROMPT_COMMAND=__prompt_command

# prompt
simple-prompt() {
	# shellcheck disable=SC2206
	__PROMPT_COMMAND_FUNCS=( ${__PROMPT_COMMAND_FUNCS[*]/__default_prompt} )

	PS1='\[\e[0m\e[32m\]\u'
	if [[ -v SSH_CONNECTION ]]; then
		PS1+='\[\e[33m\]@\H'
	fi
	PS1+=' \[\e[34m\]\W \$\[\e[0m\] '
	PS2='> '
}

__default_prompt() {
	local status=$1
	local -A COLOR=(
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

	PS1="${COLOR[default]}"

	if (( status != 0 )); then
		PS1+="${COLOR[red]} ${status} "
	fi

	local njobs
	njobs="$(jobs -p | wc -l)"
	if (( njobs != 0 )); then
		PS1+="${COLOR[orange]} ${njobs} "
	fi

	PS1+="${COLOR[magenta]}"' \s '

	if (( EUID == 0 )); then
		PS1+=$'\u2502 \u '
	else
		PS1+="${COLOR[green]}"' \u '
	fi

	if [[ -v SSH_CONNECTION ]]; then
		PS1+="${COLOR[yellow]}"' \H '
	fi

	PS1+="${COLOR[gray]}"' \W '"${COLOR[default]}"

	if [[ -v TMUX ]]; then
		PS1+=$'\u00A0'
	else
		PS1+=' '
	fi

	local width
	width="$(echo -n "${PS1@P}" | sed 's/\x01[^\x02]*\x02//g' | wc -L)"
	printf -v PS2 "${COLOR[default]}${COLOR[gray]} %*s ${COLOR[default]} " $((width-3)) "..."
}

if [[ "$(tput colors 2>/dev/null)" -ge 256 ]]; then
	__PROMPT_COMMAND_FUNCS+=( __default_prompt )
else
	simple-prompt
fi

# gpg-agent
if exists gpgconf; then
	unset SSH_AGENT_PID
	SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
	GPG_TTY="$(tty)"
	export SSH_AUTH_SOCK GPG_TTY

	__gpg_agent_updatestartuptty() {
		( gpg-connect-agent updatestartuptty /bye >/dev/null 2>&1 & )
	}
	__PROMPT_COMMAND_FUNCS+=( __gpg_agent_updatestartuptty )
fi

# dircolors
if exists dircolors; then
	if [[ -f ~/.config/dircolors ]]; then
		eval "$(dircolors -b ~/.config/dircolors)"
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
