#!/bin/bash
#### prompt ####

# taken from https://github.com/square/dotfiles.git

RED="\[\033[0;31m\]"
BROWN="\[\033[0;33m\]"
CYAN="\[\e[01;36m\]"
GREEN="\[\e[01;32m\]"
GREY="\[\033[0;97m\]"
BLUE="\[\033[0;34m\]"
PS_CLEAR="\[\033[0m\]"
SCREEN_ESC="\[\033k\033\134\]"

if [ "$LOGNAME" = "root" ]; then
    COLOR1="${RED}"
    COLOR2="${BROWN}"
    P="#"
else
    COLOR1="${BLUE}"
    COLOR2="${BROWN}"
    P="\$"
fi

prompt_simple() {
    unset PROMPT_COMMAND
    PS1="[\u@\h:\w]\$ "
    PS2="> "
}

prompt_compact() {
    unset PROMPT_COMMAND
    PS1="${COLOR1}${P}${PS_CLEAR} "
    PS2="> "
}

prompt_color() {
    PS1="[${COLOR1}\u${GREY}@${COLOR2}\h${GREY}:${COLOR1}\W${GREY}]${COLOR2}$P${PS_CLEAR} "
    PS2="\[;1m\]continue \[m\]> "
}

prompt_color_git() {
    PS1="${GREEN}\u@\h${CYAN} \w \$(__git_ps1 '(%s) ')$P${PS_CLEAR} "
    PS2="\[;1m\]continue \[m\]> "
}

# Use the color prompt by default when interactive
prompt_color