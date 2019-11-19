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

  # check completions
  COMP_WORDS=("${WORDS[@]}")
  COMP_CWORD="${CWORD}"
  COMP_LINE="${LINE}"
  COMP_POINT=$[$(wc --chars  <<< $COMP_LINE) - 1]

  _${COMMAND_NAME}_completions

  if [[ "${COMPREPLY[*]}" = "${EXPECTED}" ]]; then
    echo "${COMMAND_NAME} (${ID}): success"
  else
    echo "${COMMAND_NAME} (${ID}): fail"
    echo "Got: ${COMPREPLY[*]}"
    echo "Expected: ${EXPECTED}"
    exit 1
  fi
}

# Run tests

./node_modules/.bin/completely singleArgOneOf.json > singleArgOneOf.sh
source singleArgOneOf.sh
run_test singleArgOneOf 1 "singleArgOneOf " 1 "foo bar baz qux"
run_test singleArgOneOf 2 "singleArgOneOf b" 1 "bar baz"
run_test singleArgOneOf 3 "singleArgOneOf q" 1 "qux"
run_test singleArgOneOf 4 "singleArgOneOf z" 1 ""

./node_modules/.bin/completely multipleTwoCommands.json > multipleTwoCommands.sh
source multipleTwoCommands.sh
run_test multipleTwoCommands 1 "multipleTwoCommands " 1 "foo bar"
run_test multipleTwoCommands 2 "multipleTwoCommands f" 1 "foo"
run_test multipleTwoCommands 3 "multipleTwoCommands b" 1 "bar"
run_test multipleTwoCommands 4 "multipleTwoCommands z" 1 ""

./node_modules/.bin/completely singleTwoArgs.json > singleTwoArgs.sh
source singleTwoArgs.sh
run_test singleTwoArgs 1 "singleTwoArgs " 1 "foo bar baz qux"
run_test singleTwoArgs 2 "singleTwoArgs f" 1 "foo"
run_test singleTwoArgs 3 "singleTwoArgs b" 1 "bar baz"
run_test singleTwoArgs 4 "singleTwoArgs z" 1 ""
cd cwd && run_test singleTwoArgs 5 "singleTwoArgs foo f" 2 "file1 file2" && cd ..
cd cwd && run_test singleTwoArgs 6 "singleTwoArgs foo a" 2 "anotherfile" && cd ..

./node_modules/.bin/completely subcommandsWithColon.json > subcommandsWithColon.sh
source subcommandsWithColon.sh
run_test subcommandsWithColon 1 "subcommandsWithColon " 1 "foo:bar bar:baz qux quux"
run_test subcommandsWithColon 2 "subcommandsWithColon f" 1 "foo:bar"
run_test subcommandsWithColon 3 "subcommandsWithColon foo:b" 1 "bar"
run_test subcommandsWithColon 4 "subcommandsWithColon q" 1 "qux quux"
