#!/bin/zsh

umask 022

for file in /etc/profile.env(N-.) /etc/profile.d/*.sh(N-.); do
	source ${file}
done
unset ROOTPATH file

path=(
	${HOME}/.bin(N-/)
	${HOME}/.cargo/bin(N-/)
	${HOME}/.deno/bin(N-/)
	${HOME}/.go/bin(N-/)
	${HOME}/.local/bin(N-/)
	${^path}(N-/)
)
