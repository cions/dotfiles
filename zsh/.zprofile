#!/bin/zsh

umask 022

[[ -r /etc/profile.env ]] && source /etc/profile.env

for shfile in /etc/profile.d/*.sh(N-.r); do
    source $shfile
done

unset ROOTPATH shfile

if (( ${EUID} == 0 )); then
    gopath=( /usr/local/go )
    path=( {/usr/local/go,/usr/local,/usr,,/opt}/{sbin,bin}(N-/) )
else
    gopath=( /usr/local/go ${HOME} )
    path=( {/usr/local/go,/usr/local,/usr,,/opt}/bin(N-/) )
fi
path=( ${HOME}/{.local/,}bin(N-/) ${path} )
