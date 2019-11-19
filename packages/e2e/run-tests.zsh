#!/usr/bin/env zsh

mkdir -p zsh_completions

run_test() {
  cd cwd
  local commandName=$1
  local id=$2
  local line=$3
  local expected=$5

  local result=$(../capture.zsh "${line}" | tr -d '\015' | tr '\n' ' ' | sed 's/ $//')

  if [ "${result}" = "${expected}" ]; then
    echo "${commandName} (${id}): success"
  else
    echo "${commandName} (${id}): fail"
    echo "Got: '${result}'"
    echo "Expected: '${expected}'"
    exit 1
  fi

  cd ..
}

./node_modules/.bin/completely --shell zsh singleArgOneOf.json > zsh_completions/_singleArgOneOf
run_test singleArgOneOf 1 "singleArgOneOf " 1 "foo bar baz qux"
run_test singleArgOneOf 2 "singleArgOneOf b" 1 "bar baz"
run_test singleArgOneOf 3 "singleArgOneOf q" 1 "qux"
run_test singleArgOneOf 4 "singleArgOneOf z" 1 ""

./node_modules/.bin/completely --shell zsh multipleTwoCommands.json > zsh_completions/_multipleTwoCommands
run_test multipleTwoCommands 1 "multipleTwoCommands " 1 "foo bar"
run_test multipleTwoCommands 2 "multipleTwoCommands f" 1 "foo"
run_test multipleTwoCommands 3 "multipleTwoCommands b" 1 "bar"
run_test multipleTwoCommands 4 "multipleTwoCommands z" 1 ""

./node_modules/.bin/completely --shell zsh singleTwoArgs.json > zsh_completions/_singleTwoArgs
run_test singleTwoArgs 1 "singleTwoArgs " 1 "foo bar baz qux"
run_test singleTwoArgs 2 "singleTwoArgs f" 1 "foo"
run_test singleTwoArgs 3 "singleTwoArgs b" 1 "bar baz"
run_test singleTwoArgs 4 "singleTwoArgs z" 1 ""
run_test singleTwoArgs 5 "singleTwoArgs foo f" 2 "file1 file2"
run_test singleTwoArgs 6 "singleTwoArgs foo a" 2 "anotherfile"

./node_modules/.bin/completely --shell zsh subcommandsWithColon.json > zsh_completions/_subcommandsWithColon
run_test subcommandsWithColon 1 "subcommandsWithColon " 1 "foo:bar bar:baz qux quux"
run_test subcommandsWithColon 2 "subcommandsWithColon f" 1 "foo:bar"
run_test subcommandsWithColon 3 "subcommandsWithColon foo:b" 1 "foo:bar"
run_test subcommandsWithColon 4 "subcommandsWithColon q" 1 "qux quux"
