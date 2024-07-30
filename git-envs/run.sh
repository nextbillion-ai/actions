#!/bin/bash
set -e

echo "CI_COMMIT_SHA=$GITHUB_SHA" >> $GITHUB_ENV
echo "CI_COMMIT_AUTHOR=$GITHUB_PUSHER_NAME" >> $GITHUB_ENV
if [[ "$GITHUB_REF" == refs/tags/* ]]; then
    echo "CI_COMMIT_TAG=${GITHUB_REF#refs/tags/}" >> $GITHUB_ENV
fi