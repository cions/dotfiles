#!/bin/zsh

autoload -Uz add-zsh-hook
zmodload zsh/complist
zmodload zsh/datetime
zmodload zsh/mapfile
zmodload zsh/parameter
zmodload zsh/terminfo

DOTFILES=${${(%):-%x}:A:h:h}

# plugins
loadplugin() {
	if [[ ! -d ${ZDOTDIR}/.plugins/${argv[1]:t} ]]; then
		git clone \
			--depth=1 --recurse-submodules --shallow-submodules \
			https://github.com/${argv[1]}.git \
			${ZDOTDIR}/.plugins/${argv[1]:t} || return
	fi
	source ${ZDOTDIR}/.plugins/${argv[1]:t}/${argv[2]:-*.plugin.zsh}
}

zupdate() {
	local repo
	for repo in ${ZDOTDIR}/.plugins/*; do
		git -C ${repo} fetch --depth=1 && git -C ${repo} reset --merge FETCH_HEAD
	done
}

install -Dm644 /dev/null "${XDG_CACHE_HOME:-${HOME}/.cache}/fsh/secondary_theme.zsh"

loadplugin mafredri/zsh-async
loadplugin zdharma-continuum/fast-syntax-highlighting && fast-theme -q ${ZDOTDIR}/theme.ini
if [[ -O ${DOTFILES} ]]; then
	source ${DOTFILES}/zsh/init.zsh
else
	loadplugin cions/dotfiles zsh/init.zsh
fi

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

# commands
autoload -Uz zargs
autoload -Uz zmv

args() {
	print -rl -- "${(@q+)argv}"
}

mkcd() {
	mkdir -p -- "${argv[1]}" && cd -- "${argv[1]}"
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

rm() {
	print -u2 "zsh: error: rm command is disabled. use \`rmv\` or \`remove\` instead."
	return 1
}

crcurl() {
	command curl \
		--compressed --http3 \
		--variable VERSION="$(_chromium_version)" \
		--header 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7' \
		--header 'Accept-Encoding: gzip, deflate, br, zstd' \
		--header 'Accept-Language: en-US,en;q=0.9' \
		--expand-header 'Sec-Ch-Ua: "Not_A Brand";v="8", "Chromium";v="{{VERSION}}", "Google Chrome";v="{{VERSION}}"' \
		--header 'Sec-Ch-Ua-Mobile: ?0' \
		--header 'Sec-Ch-Ua-Platform: "Windows"' \
		--header 'Sec-Fetch-Dest: document' \
		--header 'Sec-Fetch-Mode: navigate' \
		--header 'Sec-Fetch-Site: none' \
		--header 'Sec-Fetch-User: ?1' \
		--header 'Upgrade-Insecure-Requests: 1' \
		--expand-header 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/{{VERSION}}.0.0.0 Safari/537.36' \
		"$@"
}

crfetch() {
	command curl \
		--compressed --http3 \
		--variable VERSION="$(_chromium_version)" \
		--header 'Accept: */*' \
		--header 'Accept-Encoding: gzip, deflate, br, zstd' \
		--header 'Accept-Language: en-US,en;q=0.9' \
		--expand-header 'Sec-Ch-Ua: "Not_A Brand";v="8", "Chromium";v="{{VERSION}}", "Google Chrome";v="{{VERSION}}"' \
		--header 'Sec-Ch-Ua-Mobile: ?0' \
		--header 'Sec-Ch-Ua-Platform: "Windows"' \
		--header 'Sec-Fetch-Dest: empty' \
		--header 'Sec-Fetch-Mode: cors' \
		--header 'Sec-Fetch-Site: same-origin' \
		--expand-header 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/{{VERSION}}.0.0.0 Safari/537.36' \
		"$@"
}

# aliases
if (( ${+commands[eza]} )); then
	alias ls='eza --classify --no-quotes --sort=Name'
	alias la='eza --classify --no-quotes --sort=Name --all'
	alias lA='eza --classify --no-quotes --sort=Name --all'
	alias lt='eza --classify --no-quotes --sort=Name --all --tree'
	alias ll='eza --classify --no-quotes --sort=Name --all --long --binary --group --time-style=long-iso'
	alias llt='eza --classify --no-quotes --sort=Name --all --long --tree --binary --group --time-style=long-iso'
elif (( ${+commands[dircolors]} )); then
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
if (( ${+commands[dircolors]} )); then
	alias grep='grep --color=auto'
fi
if (( ${+commands[bat]} )); then
	alias cat='bat'
fi
if (( ${+commands[rg]} )); then
	alias rga="rg --hidden --glob='!.git/'"
fi
if (( ${+commands[fend]} )); then
	alias calc='fend'
else
	alias calc='bc -l'
fi
alias remove='command rm'
alias reload='exec -l ${SHELL}'
alias p='print -rC1 --'
alias addhist='return 0;'
alias run-help='man'

alias -g G='| grep -P -e '
alias -g GV='| grep -v -P -e '
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
bindkey -M main "^@" zle-toggle-addhist
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
bindkey -M main "^X^O" expand
bindkey -M main "^X^R" redo
bindkey -M main "^X^U" undo
bindkey -M main "^X^W" zle-backward-kill-whole-word
bindkey -M main "^X^X" _complete_help
bindkey -M main "^[." insert-last-word
bindkey -M main "^[[3~" delete-char
bindkey -M main "^[[200~" bracketed-paste
bindkey -M main "^[[A" up-line-or-history
bindkey -M main "^[[B" down-line-or-history
bindkey -M main "^[[C" forward-char
bindkey -M main "^[[D" backward-char
bindkey -M main "^[b" backward-word
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
	[[ ${CONTEXT} != start ]] && return 0
	[[ -n ${BUFFER} ]] && return 0
	[[ -z ${ZLE_LINE_ABORTED} ]] && return 0
	[[ ${ZLE_LINE_ABORTED} == ${history[$((HISTCMD-1))]} ]] && return 0

	BUFFER=${ZLE_LINE_ABORTED}
	CURSOR=${#BUFFER}
	zle split-undo
	BUFFER=""
	CURSOR=0
	unset ZLE_LINE_ABORTED
}
zle -N zle-line-init

zle-line-finish() {
	ZLE_LINE_ABORTED="${PREBUFFER}${BUFFER}"
}
zle -N zle-line-finish

# chdir
autoload -Uz chpwd_recent_dirs
add-zsh-hook chpwd chpwd_recent_dirs

add-zsh-hook chpwd chpwd-hook-direnv
add-zsh-hook chpwd chpwd-hook-ls

zstyle ':completion:*' recent-dirs-insert both
zstyle ':chpwd:*' recent-dirs-max 1000
zstyle ':chpwd:*' recent-dirs-default yes
zstyle ':chpwd:*' recent-dirs-file ${ZDOTDIR}/.recent-dirs
zstyle ':chpwd:*' recent-dirs-pushd yes

# history
add-zsh-hook zshaddhistory add-history

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
	print -v 'psvar[1]' -P '%m'
fi
if [[ -v TMUX ]]; then
	psvar[2]=$'\u00A0'
else
	psvar[2]=' '
fi

simple-prompt() {
	add-zsh-hook -d precmd __update_prompt2
	disable-rprompt

	PROMPT="%f%k%b%(?::%F{red}(%?%) )%(!:%F{magenta}:%F{green})%n%1(V:%F{yellow}@%1v:)%F{blue} %1~ %(!:#:$)%f%k%b "
	PROMPT2="%f%k%b%F{blue}%1_>%f%k%b "
}

default-prompt() {
	add-zsh-hook precmd __update_prompt2

	PROMPT="%f%k%b%F{235}%(?::%K{203} %? )%1(j:%K{216} %j :)%(!:%K{207}:%K{156}) %n %1(V:%K{227} %1v :)%F{255}%K{245} %1~ %f%k%b%2v"
	PLAINPROMPT="%(?:: %? )%1(j: %j :) %n %1(V: %1v :) %1~  "
	PROMPT2="%f%k%b%F{255}%K{245} %1_ %f%k%b "
}

enable-rprompt() {
	if ! (( ${+functions[async_start_worker]} )); then
		print -u2 "zsh: error: zsh-async is unavailable"
		return 1
	fi

	async_start_worker rprompt_worker -u
	async_register_callback rprompt_worker __rprompt_callback
	add-zsh-hook precmd __update_rprompt

	default-prompt
}

disable-rprompt() {
	if (( ${+functions[async_start_worker]} )); then
		async_unregister_callback rprompt_worker
		async_stop_worker rprompt_worker
	fi
	add-zsh-hook -d precmd __update_rprompt

	RPROMPT=""
}

__update_prompt2() {
	local expanded="${(%)PLAINPROMPT}"
	local width="${#expanded}"
	PROMPT2="%b%F{255}%K{245} %$((width-3))<<${(l:width:)}%1_%<< %b "
}

__update_rprompt() {
	local workdir=${PWD}
	[[ ${workdir} == ${HOME} ]] && workdir=${DOTFILES}
	RPROMPT=""
	async_job rprompt_worker __rprompt_generator ${workdir} 2>/dev/null || {
		async_start_worker rprompt_worker -u
		async_register_callback rprompt_worker __rprompt_callback
		async_job rprompt_worker __rprompt_generator ${workdir}
	}
}

__rprompt_generator() {
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
			print -f "%s %s " $'\u2502' "${gitstate[target_name]}"
		fi
	fi

	local gitstatus=()
	(( gitstate[ahead]       )) && gitstatus+=( "A${gitstate[ahead]}" )
	(( gitstate[behind]      )) && gitstatus+=( "B${gitstate[behind]}" )
	(( gitstate[unmerged]    )) && gitstatus+=( "!${gitstate[unmerged]}" )
	(( gitstate[staged]      )) && gitstatus+=( "*${gitstate[staged]}" )
	(( gitstate[wt_modified] )) && gitstatus+=( "+${gitstate[wt_modified]}" )
	(( gitstate[wt_deleted]  )) && gitstatus+=( "-${gitstate[wt_deleted]}" )
	(( gitstate[untracked]   )) && gitstatus+=( "?${gitstate[untracked]}" )
	(( gitstate[stash]       )) && gitstatus+=( ">${gitstate[stash]}" )
	(( ${#gitstatus} > 0 )) && print -n "%K{227} ${(j: :)gitstatus} "

	return 0
}

__rprompt_callback() {
	local returncode=${argv[2]}
	local stdout=${argv[3]}
	(( returncode != 0 )) && return ${returncode}
	RPROMPT=${stdout}
	zle reset-prompt
}

if (( terminfo[colors] >= 256 )); then
	default-prompt
	if (( ${+functions[async_start_worker]} )); then
		enable-rprompt
	fi
else
	simple-prompt
fi

# gpg-agent
if (( ${+commands[gpgconf]} )); then
	unset SSH_AGENT_PID
	export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
	export GPG_TTY=${TTY}

	__gpg_agent_updatestartuptty() {
		( gpg-connect-agent updatestartuptty /bye >/dev/null 2>&1 & )
	}
	add-zsh-hook preexec __gpg_agent_updatestartuptty
fi

# dircolors
if (( ${+commands[dircolors]} )); then
	if [[ -f ~/.config/dircolors ]]; then
		eval "$(dircolors -b ~/.config/dircolors)"
	elif [[ -f /etc/DIR_COLORS ]]; then
		eval "$(dircolors -b /etc/DIR_COLORS)"
	else
		eval "$(dircolors -b)"
	fi
	zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
fi

# zrecompile
() {
	local file
	for file in ${ZDOTDIR}/.zprofile ${ZDOTDIR}/.zshrc; do
		if [[ ! -f ${file}.zwc || ${file} -nt ${file}.zwc ]]; then
			zcompile ${file}
		fi
	done
}

# environment variables
export LANG="en_US.UTF-8"
export EDITOR="vim"
export VISUAL="vim"
export PAGER="less"

export LESS="-FMRSgi -j.5 -z-4"
export LESSHISTFILE="-"
