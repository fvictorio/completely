#!/usr/bin/env bash

# source bash-completion
source /etc/bash_completion

run_test() {
  local COMMAND_NAME="$1"
  shift
  local ID="$1"
  shift
  local LINE="$1"
  shift
  local CWORD="$1"
  shift
  local EXPECTED="$1"
  shift
  local WORDS=(${LINE})

  source ${COMMAND_NAME}.sh

  # check completions
  COMP_WORDS=("${WORDS[@]}")
  COMP_CWORD="${CWORD}"
  COMP_LINE="${LINE}"
  COMP_POINT=$[$(wc --chars  <<< $COMP_LINE) - 1]

  _${COMMAND_NAME}_completions

  if [ "${COMPREPLY[*]}" == "${EXPECTED}" ]; then
    echo "${COMMAND_NAME} (${ID}): success"
  else
    echo "${COMMAND_NAME} (${ID}): fail"
    echo "Got: ${COMPREPLY[*]}"
    echo "Expected: ${EXPECTED}"
    exit 1
  fi
}

# generate completion script
../cli/bin/run singleArgOneOf.json > singleArgOneOf.sh

# run tests
run_test singleArgOneOf 1 "singleArgOneOf " 1 "foo bar baz qux"
run_test singleArgOneOf 2 "singleArgOneOf b" 1 "bar baz"
run_test singleArgOneOf 3 "singleArgOneOf q" 1 "qux"
