#/usr/bin/env bash

# helper method
declare -f _contains_element > /dev/null || _contains_element() {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

_{{commandName}}_completions()
{
  # get current word, words array, current word index, and previous word, ignoring ":" as a wordbreak
  local cur cword words
  _get_comp_words_by_ref -n ":" cur words cword prev

  # complete subcommands list
  if [ "$cword" -eq "1" ] && [ "{{ subcommandsList }}" != "" ]; then
    COMPREPLY=($(compgen -W "{{ subcommandsList }}" -- "$cur"))
    __ltrim_colon_completions "$cur"
    return
  fi

  local subcommand="${words[1]}"

  local args used_flags used_args index

  # register completions for each subcommand
  {{#each subcommands}}
  {{#if name}}
  if [ "${subcommand}" == "{{name}}" ]; then
    local args_shift=2
  {{else}}
  if true; then
    local args_shift=1
  {{/if}}
    # get the list of already used flags and args, ignoring the current word
    args=("${words[@]:args_shift}") # args without command and subcommand
    used_flags=()
    used_args=()
    index=0

    while [ "${#args[@]}" -gt 0 ]; do
      if [ "${index}" -eq "$((cword-args_shift))" ]; then
        # ignore current word
        args=("${args[@]:1}")
        index=$((index+1))
        continue
      fi

      {{#each booleanFlags}}
      {{#if shortName}}
      if [ "${args[0]}" == "--{{longName}}" ] || [ "${args[0]}" == "-{{shortName}}" ]; then
      {{else}}
      if [ "${args[0]}" == "--{{longName}}" ]; then
      {{/if}}
        used_flags+=("${args[0]}")
        args=("${args[@]:1}")
        index=$((index+1))
        continue
      fi
      {{/each}}

      {{#each stringFlags}}
      {{#if shortName}}
      if [ "${args[0]}" == "--{{longName}}" ] || [ "${args[0]}" == "-{{shortName}}" ]; then
      {{else}}
      if [ "${args[0]}" == "--{{longName}}" ]; then
      {{/if}}
        used_flags+=("${args[0]}")
        args=("${args[@]:2}")
        index=$((index+2))
        continue
      fi
      {{/each}}

      if [[ "${args[0]}" != "-"* ]]; then
        used_args+=("${args[0]}")
      fi
      args=("${args[@]:1}")
      index=$((index+1))
    done

    {{#each stringFlags}}
    {{#if shortName}}
    if [ $prev == "--{{longName}}" ] || [ $prev == "-{{shortName}}" ]; then
    {{else}}
    if [[ $prev == "--{{longName}}" ]]; then
    {{/if}}
      COMPREPLY=()
      {{#if completion.files}}
      COMPREPLY=($(compgen -f -- "$cur"))
      {{/if}}
      {{#if completion.directories}}
      COMPREPLY=($(compgen -d -- "$cur"))
      {{/if}}
      {{#if completion.oneOf}}
      COMPREPLY=($(compgen -W "{{ completion.oneOf }}" -- "$cur"))
      {{/if}}
      return
    fi
    {{/each}}

    if [[ $cur == -* ]]; then
      # flags
      completion=()

      if [[ $cur != --* ]]; then
        true
        {{#each booleanFlags}}
          {{#if shortName}}
          if ! _contains_element "-{{shortName}}" "${used_flags[@]}"; then
            completion+=("-{{shortName}}")
          fi
          {{/if}}
        {{/each}}
        {{#each stringFlags}}
          {{#if shortName}}
          if ! _contains_element "-{{shortName}}" "${used_flags[@]}"; then
            completion+=("-{{shortName}}")
          fi
          {{/if}}
        {{/each}}
      fi

      {{#each booleanFlags}}
        if ! _contains_element "--{{longName}}" "${used_flags[@]}"; then
          completion+=("--{{longName}}")
        fi
      {{/each}}
      {{#each stringFlags}}
        if ! _contains_element "--{{longName}}" "${used_flags[@]}"; then
          completion+=("--{{longName}}")
        fi
      {{/each}}

      COMPREPLY=($(compgen -W "${completion[*]}" -- "$cur"))
      return
    fi

    {{#each args}}
    if [[ "${#used_args[@]}" -eq "{{ @index }}" ]]; then
      COMPREPLY=()
      {{#if completion.files}}
      COMPREPLY=($(compgen -f -- "$cur"))
      {{/if}}
      {{#if completion.directories}}
      COMPREPLY=($(compgen -d -- "$cur"))
      {{/if}}
      {{#if completion.oneOf}}
      COMPREPLY=($(compgen -W "{{ completion.oneOf }}" -- "$cur"))
      {{/if}}
      {{#if completion.command}}
      if {{#commandsExist completion.requiredCommands}}{{/commandsExist}}; then
        COMPREPLY=($(compgen -W "$({{{completion.command}}})" -- "$cur"))
      fi
      {{/if}}
      return
    fi
    {{/each}}

    return
  fi
  {{/each}}
}

# register completion
complete -F _{{commandName}}_completions {{commandName}}
