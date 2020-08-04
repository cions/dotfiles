#!/bin/zsh

umask 022

for i in /etc/profile.env(N-.) /etc/profile.d/*.sh(N-.); {
    source ${i}
}
unset ROOTPATH i

path=( ${HOME}/.bin(N-/) ${^path}(N-/) )
if (( EUID != 0 )) path=( ${path:#*/sbin} )

if [[ ${PREFIX} == */com.termux/* ]] export TERMUX=1

if [[ ! -v ENABLE_ICONS ]] {
    ENABLE_ICONS=1
    if [[ ${TERM} == "linux" ]] ENABLE_ICONS=0
    if (( TERMUX )) ENABLE_ICONS=0
    command locale -m 2>/dev/null | command grep -qxF UTF-8-MIG || ENABLE_ICONS=0
    export ENABLE_ICONS
}
