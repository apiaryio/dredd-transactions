#!/bin/bash
# Validates format of the commit messages on Travis CI


set -e # aborts as soon as anything returns non-zero exit status


git remote set-branches origin master
git fetch
git checkout master
git checkout -
./node_modules/.bin/commitlint --from=master
