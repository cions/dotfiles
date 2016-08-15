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
