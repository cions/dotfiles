#!/bin/bash

umask 022

[[ -f /etc/profile.env ]] && source /etc/profile.env

for shfile in /etc/profile.d/*.sh; do
    # shellcheck disable=SC1090
    [[ -f "${shfile}" ]] && source "${shfile}"
done

IFS=":" read -ra paths <<< "${PATH}"
paths=( "${HOME}/.bin" "${paths[@]}" )

# shellcheck disable=SC2123
PATH=""
for path in "${paths[@]}"; do
    [[ -d "${path}" && ":${PATH}:" != *:"${path}":* ]] || continue
    (( EUID != 0 )) && [[ "${path}" == */sbin ]] && continue
    PATH="${PATH}${PATH:+:}${path}"
done
export PATH

unset ROOTPATH shfile paths path

export GOPATH="${HOME}"
export GOBIN="${HOME}/.bin"

if [[ "${PREFIX}" == */com.termux/* ]]; then
    export TERMUX=1
fi

export ENABLE_ICONS=1
[[ "${TERM}" == "linux" ]] && unset ENABLE_ICONS
(( TERMUX )) && unset ENABLE_ICONS
command locale -m 2>/dev/null | command grep -qxF UTF-8-MIG || unset ENABLE_ICONS

# shellcheck disable=SC1090
[[ $- == *i* && -f ~/.bashrc ]] && source ~/.bashrc
