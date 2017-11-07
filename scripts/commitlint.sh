#!/bin/bash
# Validates format of the commit messages on Travis CI


set -e # aborts as soon as anything returns non-zero exit status


git fetch --unshallow
./node_modules/.bin/commitlint --from=master --to="$TRAVIS_COMMIT"
