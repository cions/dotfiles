#!/bin/bash

umask 022

[[ -f /etc/profile.env ]] && source /etc/profile.env

for shfile in /etc/profile.d/*.sh; do
    # shellcheck disable=SC1090
    [[ -f "${shfile}" ]] && source "${shfile}"
done

IFS=":" read -ra paths <<< "${PATH}"
if (( EUID == 0 )); then
    export GOPATH="/usr/local/go"
    paths=(
        "${HOME}/.bin"
        "/usr/local/go/bin"
        {/usr/local,/usr,}/{sbin,bin}
        "/opt/bin"
        "${paths[@]}"
    )
else
    export GOPATH="/usr/local/go:${HOME}"
    paths=(
        "${HOME}/.bin"
        "/usr/local/go/bin"
        {/usr/local,/usr,}/bin
        "/opt/bin"
        "${paths[@]}"
    )
fi

# shellcheck disable=SC2123
PATH=""
for path in "${paths[@]}"; do
    [[ -d "${path}" && ":${PATH}:" != *:"${path}":* ]] || continue
    (( EUID != 0 )) && [[ "${path}" == */sbin ]] && continue
    PATH="${PATH}${PATH:+:}${path}"
done
export PATH

unset ROOTPATH shfile paths path

# shellcheck disable=SC1090
[[ $- == *i* && -f ~/.bashrc ]] && source ~/.bashrc
