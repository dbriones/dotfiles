#!/bin/bash
#### git ####

function pull {
    git remote prune origin
    git pull
}

function branch {
    if ! [[ $1 =~ ^[0-9]{8}- ]] ; then
        echo "Please provide a PivotalTracker story ID at the beginning of your branch name, followed by a hyphen."
        echo "example: branch 49564377-add-auto-string-for-git-commit"
	return 1
    fi

    git checkout -b $1
    git push --set-upstream origin $1
}

function delbranch {
    git push origin --delete $1
    git branch -D $1
}
