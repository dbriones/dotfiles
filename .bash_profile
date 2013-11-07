# Prompts
export PS1="\u@\h:\W>"
export PS2="\u@\h:\W=>"

# Aliases
alias fn='find . -name'
alias ffs='sudo'
alias ll='ls -l'

# Bash Completion
if [ -f `brew --prefix`/etc/bash_completion ]; then
     . `brew --prefix`/etc/bash_completion
fi

# see: http://stufftohelpyouout.blogspot.com/2010/01/show-name-of-git-branch-in-prompt.html
# see also: http://superuser.com/questions/31744/how-to-get-git-completion-bash-to-work-on-mac-os-x
# see also: http://stackoverflow.com/questions/347901/what-are-your-favorite-git-features-or-tricks
# This assumes you have installed Homebrew ( http://github.com/mxcl/homebrew )
# and then installed Git via Homebrew with the default installation location:
# ruby -e "$(curl -fsS http://gist.github.com/raw/323731/install_homebrew.rb)"
# brew install wget
# brew install git
# brew update
if [ -f /usr/local/etc/bash_completion.d/git-completion.bash ]; then
  . /usr/local/etc/bash_completion.d/git-completion.bash;
  export PS1='\[\033[01;32m\]\h\[\033[01;36m\] \W\[\033[01;33m\]$(__git_ps1)\[\033[00m\] $ '
fi

