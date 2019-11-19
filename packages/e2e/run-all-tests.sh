#!/usr/bin/env sh

set -e

echo "Running tests for bash"
bash --noprofile --norc -i -c 'source run-tests.sh'
echo ""

echo "Running tests for zsh"
zsh -i -d -f -c 'source run-tests.zsh'
echo ""
