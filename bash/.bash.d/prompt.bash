#!/bin/bash
#### prompt ####

# taken from https://github.com/square/dotfiles.git

NORM_RED="\[\e[0;31m\]"
NORM_BROWN="\[\e[0;33m\]"
NORM_GREY="\[\e[0;97m\]"
NORM_BLUE="\[\e[0;34m\]"

BOLD_CYAN="\[\e[01;36m\]"
BOLD_GREEN="\[\e[01;32m\]"
BOLD_YELLOW="\[\e[01;33m\]"

PS_CLEAR="\[\e[0m\]"
SCREEN_ESC="\[\ek\e\134\]"

if [ "$LOGNAME" = "root" ]; then
    COLOR1="${NORM_RED}"
    COLOR2="${NORM_BROWN}"
    P="#"
else
    COLOR1="${NORM_BLUE}"
    COLOR2="${NORM_BROWN}"
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
    PS1="[${COLOR1}\u${NORM_GREY}@${COLOR2}\h${NORM_GREY}:${COLOR1}\W${NORM_GREY}]${COLOR2}$P${PS_CLEAR} "
    PS2="${NORM_RED}continue ${PS_CLEAR}> "
}

# see: http://stufftohelpyouout.blogspot.com/2010/01/show-name-of-git-branch-in-prompt.html
# see also: http://superuser.com/questions/31744/how-to-get-git-completion-bash-to-work-on-mac-os-x
# see also: http://stackoverflow.com/questions/347901/what-are-your-favorite-git-features-or-tricks
# This assumes you have installed Homebrew ( http://github.com/mxcl/homebrew )
# and then installed Git via Homebrew with the default installation location:
# ruby -e "$(curl -fsS http://gist.github.com/raw/323731/install_homebrew.rb)"
# brew install wget
# brew install git
# brew update


prompt_color_git() {
  if [ -f /usr/local/etc/bash_completion.d/git-completion.bash ]
  then
    . /usr/local/etc/bash_completion.d/git-completion.bash;
    PS1="${BOLD_GREEN}\h${BOLD_CYAN} \W${BOLD_YELLOW}\$(__git_ps1)${PS_CLEAR} $ "
    PS2="${NORM_RED}continue ${PS_CLEAR}> "
  fi
}

prompt_color_git
