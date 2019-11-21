#!/usr/bin/env bash

# source bash-completion
source /etc/bash_completion

mkdir -p bash_completions

run_test() {
  cd cwd

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

  cd ..
}

# Run tests

./node_modules/.bin/completely fixtures/oneArgOneFlag.json > bash_completions/oneArgOneFlag.sh
source bash_completions/oneArgOneFlag.sh
run_test oneArgOneFlag 1 "oneArgOneFlag " 1 "foo bar baz qux"
run_test oneArgOneFlag 2 "oneArgOneFlag b" 1 "bar baz"
run_test oneArgOneFlag 3 "oneArgOneFlag q" 1 "qux"
run_test oneArgOneFlag 4 "oneArgOneFlag z" 1 ""
run_test oneArgOneFlag 5 "oneArgOneFlag -" 1 "--myflag"
run_test oneArgOneFlag 6 "oneArgOneFlag --myflag -" 2 ""

./node_modules/.bin/completely fixtures/twoSubcommands.json > bash_completions/twoSubcommands.sh
source bash_completions/twoSubcommands.sh
run_test twoSubcommands 1 "twoSubcommands " 1 "foo bar"
run_test twoSubcommands 2 "twoSubcommands f" 1 "foo"
run_test twoSubcommands 3 "twoSubcommands b" 1 "bar"
run_test twoSubcommands 4 "twoSubcommands z" 1 ""
run_test twoSubcommands 5 "twoSubcommands foo -" 2 "--flag"
run_test twoSubcommands 6 "twoSubcommands foo --flag " 3 "somedir anotherdir"

./node_modules/.bin/completely fixtures/twoArgs.json > bash_completions/twoArgs.sh
source bash_completions/twoArgs.sh
run_test twoArgs 1 "twoArgs " 1 "foo bar baz qux"
run_test twoArgs 2 "twoArgs f" 1 "foo"
run_test twoArgs 3 "twoArgs b" 1 "bar baz"
run_test twoArgs 4 "twoArgs z" 1 ""
run_test twoArgs 5 "twoArgs foo f" 2 "file1 file2"
run_test twoArgs 6 "twoArgs foo a" 2 "anotherfile anotherdir"

./node_modules/.bin/completely fixtures/subcommandsWithColon.json > bash_completions/subcommandsWithColon.sh
source bash_completions/subcommandsWithColon.sh
run_test subcommandsWithColon 1 "subcommandsWithColon " 1 "foo:bar bar:baz qux quux"
run_test subcommandsWithColon 2 "subcommandsWithColon f" 1 "foo:bar"
run_test subcommandsWithColon 3 "subcommandsWithColon foo:b" 1 "bar"
run_test subcommandsWithColon 4 "subcommandsWithColon q" 1 "qux quux"
