#!/bin/bash

umask 022

[[ -f /etc/profile.env ]] && source /etc/profile.env

for shfile in /etc/profile.d/*.sh; do
    source "${shfile}"
done

if [[ -v MSYSTEM ]]; then
    export GOROOT="/mingw64/lib/go"
    export GOPATH="/mingw64/go:${HOME}"
    IFS=":" read -ra paths <<< "${PATH}"
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
    )
else
    export GOPATH="/usr/local/go:${HOME}"
    paths=(
        "${HOME}/.bin"
        "/usr/local/go/bin"
        {/usr/local,/usr,}/bin
        "/opt/bin"
    )
fi

PATH=""
for path in "${paths[@]}"; do
    [[ -d "${path}" && ":${PATH}:" != *:"${path}":* ]] || continue
    PATH="${PATH}${PATH:+:}${path}"
done
export PATH

if command -v gpg-connect-agent >/dev/null 2>&1; then
    gpg-connect-agent updatestartuptty /bye >/dev/null 2>&1
    unset SSH_AGENT_PID
    if [[ -n "${XDG_RUNTIME_DIR}" ]]; then
        export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR}/gnupg/S.gpg-agent.ssh"
    else
        export SSH_AUTH_SOCK="${HOME}/.gnupg/S.gpg-agent.ssh"
    fi
    tty -s && export GPG_TTY="$(tty)"
fi

unset ROOTPATH shfile paths path

[[ $- == *i* && -f ~/.bashrc ]] && source ~/.bashrc
