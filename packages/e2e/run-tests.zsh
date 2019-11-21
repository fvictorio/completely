#!/usr/bin/env zsh

mkdir -p zsh_completions

run_test() {
  cd cwd
  local commandName=$1
  local id=$2
  local line=$3
  local expected=$5

  local result=$(../capture.zsh "${line}" | sort -u | tr -d '\015' | tr '\n' ' ' | sed 's/ $//')

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

./node_modules/.bin/completely --shell zsh fixtures/oneArgOneFlag.json > zsh_completions/_oneArgOneFlag
run_test oneArgOneFlag 1 "oneArgOneFlag " 1 "bar baz foo qux"
run_test oneArgOneFlag 2 "oneArgOneFlag b" 1 "bar baz"
run_test oneArgOneFlag 3 "oneArgOneFlag q" 1 "qux"
run_test oneArgOneFlag 4 "oneArgOneFlag z" 1 ""
run_test oneArgOneFlag 5 "oneArgOneFlag -" 1 "--myflag -- "
run_test oneArgOneFlag 6 "oneArgOneFlag --myflag -" 2 ""

./node_modules/.bin/completely --shell zsh fixtures/twoSubcommands.json > zsh_completions/_twoSubcommands
run_test twoSubcommands 1 "twoSubcommands " 1 "bar foo"
run_test twoSubcommands 2 "twoSubcommands f" 1 "foo"
run_test twoSubcommands 3 "twoSubcommands b" 1 "bar"
run_test twoSubcommands 4 "twoSubcommands z" 1 ""
run_test twoSubcommands 5 "twoSubcommands foo -" 2 "--flag -- "
run_test twoSubcommands 6 "twoSubcommands foo --flag " 3 "anotherdir/ somedir/"

./node_modules/.bin/completely --shell zsh fixtures/twoArgs.json > zsh_completions/_twoArgs
run_test twoArgs 1 "twoArgs " 1 "foo bar baz qux"
run_test twoArgs 2 "twoArgs f" 1 "foo"
run_test twoArgs 3 "twoArgs b" 1 "bar baz"
run_test twoArgs 4 "twoArgs z" 1 ""
run_test twoArgs 5 "twoArgs foo f" 2 "file1 file2"
run_test twoArgs 6 "twoArgs foo a" 2 "anotherdir/ anotherfile"

./node_modules/.bin/completely --shell zsh fixtures/subcommandsWithColon.json > zsh_completions/_subcommandsWithColon
run_test subcommandsWithColon 1 "subcommandsWithColon " 1 "foo:bar bar:baz qux quux"
run_test subcommandsWithColon 2 "subcommandsWithColon f" 1 "foo:bar"
run_test subcommandsWithColon 3 "subcommandsWithColon foo:b" 1 "foo:bar"
run_test subcommandsWithColon 4 "subcommandsWithColon q" 1 "qux quux"
