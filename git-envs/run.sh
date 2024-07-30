#!/bin/bash

# Fetch all tags and commits
git fetch --tags

# Extract the commit SHA
CI_COMMIT_SHA=$(git rev-parse HEAD)

# Extract the commit author
CI_COMMIT_AUTHOR=$(git log -1 --pretty=format:'%an')

# Extract the commit tag, if any
CI_COMMIT_TAG=$(git describe --tags --exact-match 2>/dev/null || echo "")

# Write outputs to the GitHub environment file
echo "CI_COMMIT_SHA=$CI_COMMIT_SHA" >> $GITHUB_ENV
echo "CI_COMMIT_AUTHOR=$CI_COMMIT_AUTHOR" >> $GITHUB_ENV
echo "CI_COMMIT_TAG=$CI_COMMIT_TAG" >> $GITHUB_ENV
