#!/bin/zsh

umask 022

if [[ -f /etc/profile.env ]] source /etc/profile.env

for shfile in /etc/profile.d/*.sh(N-.); {
    source ${shfile}
}

unset ROOTPATH shfile

path=( ${HOME}/.bin(N-/) ${path} )
if (( EUID != 0 )) {
    path=( ${path:#*/sbin} )
}

gopath=( ${HOME} )
GOBIN=${HOME}/.bin

if [[ ${PREFIX} == */com.termux/* ]] {
    export TERMUX=1
}

() {
    [[ ${TERM} == "linux" ]] && return
    (( TERMUX )) && return
    command locale -m 2>/dev/null | command grep -qxF UTF-8-MIG || return
    export ENABLE_ICONS=1
}
