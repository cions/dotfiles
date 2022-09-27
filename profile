#!/bin/sh

umask 022

for file in /etc/profile.env /etc/profile.d/*.sh; do
    [ -f "${file}" ] && . "${file}"
done

PATH="${HOME}/.bin:${HOME}/.go/bin:${HOME}/.cargo/bin:${HOME}/.deno/bin:${PATH}"
OLDIFS="${IFS}"
IFS=":"
NEWPATH=""
for path in ${PATH}; do
    if [ ! -d "${path}" ]; then
        continue
    fi
    case "${path}" in
        */sbin)
            if [ "$(id -u)" != 0 ]; then
                continue
            fi
            ;;
    esac
    case ":${NEWPATH}:" in
        *":${path}:"*)
            continue
            ;;
    esac
    NEWPATH="${NEWPATH}${NEWPATH:+:}${path}"
done
export PATH="${NEWPATH}"
IFS="${OLDIFS}"

unset GCC_SPECS ROOTPATH NEWPATH OLDIFS file path

case "${BASH_VERSION+set}:$-" in
    set:*i*) [ -f ~/.bashrc ] && . ~/.bashrc ;;
esac

#shellcheck disable=SC1090
