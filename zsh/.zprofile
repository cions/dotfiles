#!/bin/zsh

umask 022

[[ -r /etc/profile.env ]] && source /etc/profile.env

for shfile in /etc/profile.d/*.sh(N-.r); do
    source $shfile
done

unset ROOTPATH shfile

if (( ${+MSYSTEM} )); then
    export GOROOT="/mingw64/lib/go"
    gopath=( /mingw64/go ${HOME} )
    path=( ${HOME}/bin(N-/) /mingw64/go/bin(N-/) ${path} )
else
    gopath=( /usr/local/go ${HOME} )
    path=(
        ${HOME}/bin(N-/)
        ${HOME}/.local/bin(N-/)
        ${^gopath}/bin(N-/)
        {/usr/local,/usr,}/{sbin,bin}(N-/)
        /opt/bin(N-/)
    )
    if (( ${EUID} == 0 )); then
        path=( "${(@)path:#*/sbin}" )
    fi
fi
