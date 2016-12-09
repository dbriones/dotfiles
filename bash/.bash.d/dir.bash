#!/bin/bash
#### dir ####

function replace-all-from-clj-files {
   if [ -z "$1" ]; then
      echo $"Usage: replace-all-from-clj-files {search-string} {replacement-string}"
      echo $"   all replacement is done inline, with no backup."
      echo $"   recommended use of git repository or manual backup."
   else
      REGEX="s/$1/$2/g"
      find . -type f -name \*.clj -print0 | xargs -0 -I{} sed -i '' $REGEX {}
    fi
}
