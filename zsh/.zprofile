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

if [[ ${PREFIX} == */com.termux/* ]] {
    export TERMUX=1
}

ENABLE_ICONS=1
[[ ${TERM} == "linux" ]] && ENABLE_ICONS=0
(( TERMUX )) && ENABLE_ICONS=0
command locale -m 2>/dev/null | command grep -qxF UTF-8-MIG || ENABLE_ICONS=0
export ENABLE_ICONS

gopath=( ${HOME}/.cache/go )
GOBIN=${HOME}/.bin
