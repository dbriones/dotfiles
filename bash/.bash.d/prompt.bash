#!/bin/bash
#### prompt ####

# taken from https://github.com/square/dotfiles.git

NORM_RED="\033[0;31m"
NORM_GREEN="\033[0;32m"
NORM_YELLOW="\033[0;33m"
NORM_BLUE="\033[0;34m"
NORM_WHITE="\033[0;37m"
NORM_GREY="\033[0;97m"

BOLD_CYAN="\033[01;36m"
BOLD_GREEN="\033[01;32m"
BOLD_YELLOW="\033[01;33m"

PS_CLEAR="\033[0m"
SCREEN_ESC="\033k\e\134\]"

if [ "$LOGNAME" = "root" ]; then
    COLOR1="${NORM_RED}"
    COLOR2="${NORM_YELLOW}"
    P="#"
else
    COLOR1="${NORM_BLUE}"
    COLOR2="${NORM_YELLOW}"
    P="\$"
fi

prompt_simple() {
    unset PROMPT_COMMAND
    PS1="[\u@\h:\w]${P} "
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

function git_color {
  local git_status="$(git status 2> /dev/null)"

  if [[ ! $git_status =~ "working tree clean" ]]; then
    echo -e ${NORM_RED}
  elif [[ $git_status =~ "Your branch is ahead of" ]]; then
    echo -e ${NORM_YELLOW}
  elif [[ $git_status =~ "nothing to commit" ]]; then
    echo -e ${NORM_GREEN}
  else
    echo -e ""
  fi
}

function git_branch {
  local git_status="$(git status 2> /dev/null)"
  local on_branch="On branch ([^${IFS}]*)"
  local on_commit="HEAD detached at ([^${IFS}]*)"

  if [[ $git_status =~ $on_branch ]]; then
    local branch=${BASH_REMATCH[1]}
    echo ":$branch"
  elif [[ $git_status =~ $on_commit ]]; then
    local commit=${BASH_REMATCH[1]}
    echo ":$commit"
  fi
}

prompt_color_git() {
  if [ -f ${HOME}/.bash.d/git_completion.bash ]
  then
    . ${HOME}/.bash.d/git_completion.bash;
    PS1="\[${BOLD_GREEN}\]\n\W"          # basename of pwd
    PS1+="\[\$(git_color)\]"        # colors git status
    PS1+="\$(git_branch)"           # prints current branch
    PS1+=" \[${NORM_GREY}\]\$\[${PS_CLEAR}\] "   # '#' for root, else '$'
    #PS1=" ${BOLD_GREEN}\h${BOLD_CYAN} \W${BOLD_YELLOW}\$(__git_ps1)${PS_CLEAR} ${P} "
    PS2=" ${NORM_RED}continue ${PS_CLEAR}> "
  fi
}

if [[ -z $INSIDE_EMACS ]]; then
  prompt_color_git
else
  prompt_simple
fi
