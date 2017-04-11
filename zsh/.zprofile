#!/bin/zsh

umask 022

[[ -f /etc/profile.env ]] && source /etc/profile.env

for shfile in /etc/profile.d/*.sh(N-.); do
    source ${shfile}
done

unset ROOTPATH shfile

if (( ${+MSYSTEM} )); then
    export GOROOT="/mingw64/lib/go"
    gopath=( /mingw64/go ${HOME} )
    path=(
        ${HOME}/.bin(N-/)
        /mingw64/go/bin(N-/)
        ${path}
    )
elif (( EUID == 0 )); then
    gopath=( /usr/local/go )
    path=(
        ${HOME}/.bin(N-/)
        ${^gopath}/bin(N-/)
        {/usr/local,/usr,}/{sbin,bin}(N-/)
        /opt/bin(N-/)
    )
else
    gopath=( /usr/local/go ${HOME} )
    path=(
        ${HOME}/.bin(N-/)
        ${^gopath}/bin(N-/)
        {/usr/local,/usr,}/bin(N-/)
        /opt/bin(N-/)
    )
fi

if (( ${+commands[gpg-connect-agent]} )); then
    gpg-connect-agent updatestartuptty /bye >/dev/null 2>&1
    unset SSH_AGENT_PID
    if (( ${+XDG_RUNTIME_DIR} )); then
        export SSH_AUTH_SOCK=${XDG_RUNTIME_DIR}/gnupg/S.gpg-agent.ssh
    else
        export SSH_AUTH_SOCK=${HOME}/.gnupg/S.gpg-agent.ssh
    fi
    export GPG_TTY=${TTY}
fi
