#compdef {{commandName}}

function _{{commandName}} {
  local _line

  {{#if rootCommand}}
    _arguments -C \
    {{#each rootCommand.args}}
      {{#if completion.oneOf}}
        "{{#add @index 1}}{{/add}}: :({{completion.oneOf}})" \
      {{else if completion.files}}
        "{{#add @index 1}}{{/add}}: :_files" \
      {{else}}
        "{{#add @index 1}}{{/add}}: :()" \
      {{/if}}
    {{/each}}
    "*::arg:->args"
  {{else}}
    _arguments -C \
    "1: :({{subcommandsList}})" \
    "*::arg:->args"
  {{/if}}

  {{#if subcommands.length}}
    case $line[1] in
    {{#each subcommands}}
      {{name}})
        __{{../commandName}}_{{name}}
      ;;
    {{/each}}
    esac
  {{/if}}
}

{{#each subcommands}}
function __{{../commandName}}_{{name}} {
  {{#if stringFlags.length}}
  _arguments \
    {{#each stringFlags}}
      {{#if @last}}
      "--{{longName}}"
      {{else}}
      "--{{longName}}" \
      {{/if}}
    {{/each}}
  {{/if}}
}
{{/each}}

_{{commandName}}
