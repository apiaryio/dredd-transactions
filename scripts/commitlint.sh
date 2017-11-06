#!/bin/bash
# Validates format of the commit messages on Travis CI


set -e # aborts as soon as anything returns non-zero exit status


git fetch --unshallow

if [[ $TRAVIS_COMMIT_RANGE != "" ]]; then
    # See http://wiki.bash-hackers.org/syntax/pe#substring_removal to understand the bash magic
    ./node_modules/.bin/commitlint --from="${TRAVIS_COMMIT_RANGE%...*}" --to="${TRAVIS_COMMIT_RANGE#*...}"
else
    ./node_modules/.bin/commitlint --from=master --to="$TRAVIS_COMMIT"
fi
