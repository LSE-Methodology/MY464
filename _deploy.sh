#!/bin/sh

set -e

# Name of the folder to deploy
DEPLOY_DIR=_book

# Deploy with an empty history
cd ${DEPLOY_DIR}
git init
git add .
git commit -m "Update the GitHub pages to ${TRAVIS_COMMIT}"
git push --force --quiet "git@github.com:${GITHUB_REPO}.git" master:gh-pages
