#!/bin/bash

umask 022

[[ -f /etc/profile.env ]] && source /etc/profile.env

for shfile in /etc/profile.d/*.sh; do
    source "${shfile}"
done

IFS=":" read -ra paths <<< "${PATH}"
if [[ -v MSYSTEM ]]; then
    export GOROOT="/mingw64/lib/go"
    export GOPATH="/mingw64/go:${HOME}"
    paths=(
        "${HOME}/.bin"
        "/mingw64/go/bin"
        "${paths[@]}"
    )
elif (( EUID == 0 )); then
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

PATH=""
for path in "${paths[@]}"; do
    [[ -d "${path}" && ":${PATH}:" != *:"${path}":* ]] || continue
    PATH="${PATH}${PATH:+:}${path}"
done
export PATH

unset ROOTPATH shfile paths path

[[ $- == *i* && -f ~/.bashrc ]] && source ~/.bashrc
