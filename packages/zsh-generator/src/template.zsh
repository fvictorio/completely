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
    {{#each rootCommand.allFlags}}
      {{#stringFlag this}}{{/stringFlag}} \
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
    {{#each allFlags}}
      {{#stringFlag this}}{{/stringFlag}} \
    {{/each}}
  {{/if}}

}
{{/each}}

_{{commandName}}
