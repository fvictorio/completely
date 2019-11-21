#compdef {{commandName}}

function _{{commandName}} {
  local _line

  _arguments -C \
  {{#if rootCommand}}
    {{#each rootCommand.args}}
      {{#if completion.oneOf}}
        "{{#add @index 1}}{{/add}}: :({{completion.oneOf}})" \
      {{else if completion.files}}
        "{{#add @index 1}}{{/add}}: :_files" \
      {{else}}
        "{{#add @index 1}}{{/add}}: :()" \
      {{/if}}
    {{/each}}
    {{#each rootCommand.stringFlags}}
      {{#if completion.directories}}
      "--{{longName}}[]: :_files -/" \
      {{/if}}
    {{/each}}
    {{#each rootCommand.booleanFlags}}
      "--{{longName}}" \
    {{/each}}
  {{else}}
    "1: :({{subcommandsList}})" \
  {{/if}}
  "*::arg:->args"

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
  {{#if hasFlags}}
  _arguments \
    {{#each stringFlags}}
      {{#if completion.directories}}
      "--{{longName}}: :_dirs" \
      {{else if completion.oneOf}}
      "--{{longName}}: :({{completion.oneOf}})" \
      {{else}}
      "--{{longName}}: :_files" \
      {{/if}}
    {{/each}}
    {{#each booleanFlags}}
      "--{{longName}}" \
    {{/each}}
  {{/if}}

}
{{/each}}

_{{commandName}}
