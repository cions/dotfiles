#!/bin/zsh

umask 022

for i in /etc/profile.env(N-.) /etc/profile.d/*.sh(N-.); do
    source ${i}
done
unset ROOTPATH i

path=(
    ${HOME}/.bin(N-/)
    ${HOME}/.go/bin(N-/)
    ${HOME}/.cargo/bin(N-/)
    ${HOME}/.deno/bin(N-/)
    ${^path}(N-/)
)
(( EUID != 0 )) && path=( ${path:#*/sbin} )

[[ ${PREFIX} == */com.termux/* ]] && export TERMUX=1

if (( ! ${+ENABLE_ICONS} )); then
    ENABLE_ICONS=1
    [[ ${TERM} == "linux" ]] && ENABLE_ICONS=0
    (( TERMUX )) && ENABLE_ICONS=0
    command locale -m 2>/dev/null | command grep -qxF UTF-8-MIG || ENABLE_ICONS=0
    export ENABLE_ICONS
fi
