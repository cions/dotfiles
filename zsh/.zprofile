#!/bin/zsh

umask 022

if [[ -f /etc/profile.env ]] source /etc/profile.env

for shfile in /etc/profile.d/*.sh(N-.); {
    source ${shfile}
}

unset ROOTPATH shfile

if (( ${+MSYSTEM} )) {
    export GOROOT="/mingw64/lib/go"
    gopath=( /mingw64/go ${HOME} )
    path=(
        ${HOME}/.bin(N-/)
        /mingw64/go/bin(N-/)
        ${^path}(N-/)
    )
} elif (( EUID == 0 )) {
    gopath=( /usr/local/go )
    path=(
        ${HOME}/.bin(N-/)
        ${^gopath}/bin(N-/)
        {/usr/local,/usr,}/{sbin,bin}(N-/)
        /opt/bin(N-/)
        ${^path}(N-/)
    )
} else {
    gopath=( /usr/local/go ${HOME} )
    path=(
        ${HOME}/.bin(N-/)
        ${^gopath}/bin(N-/)
        {/usr/local,/usr,}/bin(N-/)
        /opt/bin(N-/)
        ${^path}(N-/)
    )
}
