#!/bin/bash

umask 022

[[ -f /etc/profile.env ]] && source /etc/profile.env

for shfile in /etc/profile.d/*.sh; do
    source "${shfile}"
done

export GOPATH="/usr/local/go:${HOME}"

paths=(
    "${HOME}/.local/bin"
    "${HOME}/bin"
    "/usr/local/go/bin"
)
if (( ${EUID} == 0 )); then
    paths+=(
        "/usr/local/sbin"
        "/usr/local/bin"
        "/usr/sbin"
        "/usr/bin"
        "/sbin"
        "/bin"
        "/opt/bin"
    )
else
    paths+=(
        "/usr/local/bin"
        "/usr/bin"
        "/bin"
        "/opt/bin"
    )
fi
PATH=""
for path in "${paths[@]}"; do
    [[ -d "${path}" ]] && PATH="${PATH}${PATH:+:}${path}"
done

unset ROOTPATH shfile paths path

[[ $- == *i* && -f ~/.bashrc ]] && source ~/.bashrc
