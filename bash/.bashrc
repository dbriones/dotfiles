# Load only files with a `.bash` extension -- this prevents, for
# example, Emacs temp files from being evaluated unexpectedly
#
for file in ~/.bash.d/*.bash ~/.bash-user.d/*.bash; do
	[ -r "$file" ] && source "$file"
done
unset file

# Enable some Bash 4 features when possible:
# * `autocd`, e.g. `**/qux` will enter `./foo/bar/baz/qux`
# * Recursive globbing, e.g. `echo **/*.txt`
for option in autocd globstar; do
	shopt -s "$option" 2> /dev/null
done
