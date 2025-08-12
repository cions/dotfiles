#!/bin/bash

umask 022

for file in /etc/profile.env /etc/profile.d/*.sh; do
	#shellcheck disable=SC1090
	if [[ -f "${file}" ]]; then
		source "${file}"
	fi
done
unset file

PATH="${HOME}/.bin:${HOME}/.cargo/bin:${HOME}/.deno/bin:${HOME}/.go/bin:${HOME}/.local/bin:${PATH}"

if [[ "$-" == *i* && -f "${HOME}/.bashrc" ]]; then
	# shellcheck disable=SC1091
	source "${HOME}/.bashrc"
fi
