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
  local cur="${COMP_WORDS[$COMP_CWORD]}" # current word

  # complete subcommands list
  if [ "$COMP_CWORD" -eq "1" ]; then
    COMPREPLY=($(compgen -W "{{ subcommandsList }}" -- "$cur"))
    return
  fi

  local subcommand="${COMP_WORDS[1]}"
  local prev="${COMP_WORDS[$COMP_CWORD - 1]}"

  local args used_flags used_args index
  args=("${COMP_WORDS[@]:2}") # args without command and subcommand

  # register completions for each subcommand
  {{#each subcommands}}
  if [ "${subcommand}" == "{{name}}" ]; then
    # get the list of already used flags and args, ignoring the current word
    used_flags=()
    used_args=()
    index=0

    while [ "${#args[@]}" -gt 0 ]; do
      if [ "${index}" -eq "$((COMP_CWORD-2))" ]; then
        # ignore current word
        args=("${args[@]:1}")
        index=$((index+1))
        continue
      fi

      {{#each booleanFlags}}
      if [ "${args[0]}" == "--{{longName}}" ]; then
        used_flags+=("--{{longName}}")
        args=("${args[@]:1}")
        index=$((index+1))
        continue
      fi
      {{/each}}

      {{#each stringFlags}}
      if [ "${args[0]}" == "--{{longName}}" ]; then
        used_flags+=("--{{longName}}")
        args=("${args[@]:2}")
        index=$((index+2))
        continue
      fi
      {{/each}}

      used_args+=("${args[0]}")
      args=("${args[@]:1}")
      index=$((index+1))
    done

    {{#each stringFlags}}
    if [[ $prev == "--{{longName}}" ]]; then
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
      return
    fi
    {{/each}}

    return
  fi
  {{/each}}
}

# register completion
complete -F _{{commandName}}_completions {{commandName}}
