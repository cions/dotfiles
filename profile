#!/bin/bash

umask 022

[[ -f /etc/profile.env ]] && source /etc/profile.env

for shfile in /etc/profile.d/*.sh; do
    source "${shfile}"
done

if [[ -n "${MSYSTEM:++}" ]]; then
    export GOROOT="/mingw64/lib/go"
    export GOPATH="/mingw64/go:${HOME}"
    IFS=":" read -ra paths <<< "${PATH}"
    paths=( "${HOME}/bin" "/mingw64/go/bin" "${paths[@]}" )
else
    export GOPATH="/usr/local/go:${HOME}"
    paths=(
        "${HOME}/bin"
        "${HOME}/.local/bin"
        "/usr/local/go/bin"
        "/usr/local/sbin"
        "/usr/local/bin"
        "/usr/sbin"
        "/usr/bin"
        "/sbin"
        "/bin"
        "/opt/bin"
    )
fi

PATH=""
for path in "${paths[@]}"; do
    [[ ! -d "${path}" || ":${PATH}:" == *:"${path}":* ]] && continue
    [[ "${path}" == */sbin && "${EUID}" -ne 0 ]] && continue
    PATH="${PATH}${PATH:+:}${path}"
done
export PATH

unset ROOTPATH shfile paths path

[[ $- == *i* && -f ~/.bashrc ]] && source ~/.bashrc
