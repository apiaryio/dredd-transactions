#!/bin/bash
# Validates format of the commit messages on Travis CI


set -e # aborts as soon as anything returns non-zero exit status


git remote set-branches origin master
git fetch --unshallow
git checkout master
git checkout -

./node_modules/.bin/commitlint --from=master --to="$TRAVIS_COMMIT"
