#!/bin/sh

set -e

#[ -z "${GITHUB_PAT}" ] && exit 0
#[ "${TRAVIS_BRANCH}" != "master" ] && exit 0

# git config --global user.email "kbenoit@lse.ac.uk"
# git config --global user.name "Travis CI"

git clone -b gh-pages git@github.com:LSE-Methodology/MY451.git book-output
cd book-output
cp -r ../_book/* ./
git add --all *
git commit -m "Update the book" || true
git push origin gh-pages
