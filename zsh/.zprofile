#!/bin/zsh

umask 022

for file in /etc/profile.env(N-.) /etc/profile.d/*.sh(N-.); do
    source ${file}
done
unset GCC_SPECS ROOTPATH file

path=(
    ${HOME}/.bin(N-/)
    ${HOME}/.go/bin(N-/)
    ${HOME}/.cargo/bin(N-/)
    ${HOME}/.deno/bin(N-/)
    ${^path}(N-/)
)
(( EUID != 0 )) && path=( ${path:#*/sbin} )
