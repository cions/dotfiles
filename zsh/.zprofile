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

if [[ -S /run/user/${SUDO_UID}/${WAYLAND_DISPLAY} ]]; then
	export WAYLAND_DISPLAY=/run/user/${SUDO_UID}/${WAYLAND_DISPLAY}
fi
if (( ! ${+XDG_RUNTIME_DIR} )); then
	export XDG_RUNTIME_DIR=/run
fi
