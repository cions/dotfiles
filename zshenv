#!/bin/zsh

ZDOTDIR=${HOME}/.zsh
if [[ -f ${ZDOTDIR}/.zshenv ]]; then
    source ${ZDOTDIR}/.zshenv
fi
