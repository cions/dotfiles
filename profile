#!/bin/sh

umask 022

for i in /etc/profile.env /etc/profile.d/*.sh; do
    # shellcheck disable=SC1090
    [ -f "$i" ] && . "$i"
done
unset ROOTPATH i

PATH="${HOME}/.bin:${PATH}"
if [ "$(id -u)" -ne 0 ]; then
    PATH="$(echo "${PATH}:" | sed 's@[^:]*/sbin:@@g')"
    PATH="${PATH%:}"
fi
export PATH

case "${PREFIX}" in
    */com.termux/*) export TERMUX=1 ;;
esac

ENABLE_ICONS=1
[ "${TERM}" = "linux" ] && ENABLE_ICONS=0
[ -n "${TERMUX+set}" ] && ENABLE_ICONS=0
locale -m 2>/dev/null | grep -qxF UTF-8-MIG || ENABLE_ICONS=0
export ENABLE_ICONS

# shellcheck disable=SC1090
case "${BASH+set}:$-" in
    set:*i*) [ -f ~/.bashrc ] && . ~/.bashrc ;;
esac
