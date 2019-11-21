import * as fs from 'fs'
import * as path from 'path'
import Handlebars from 'handlebars';
import { Schema } from '@completely/spec'

Handlebars.registerHelper('add', (x: string, y: string) => {
  return String(+x + +y)
})

const template = fs.readFileSync(path.join(__dirname, 'template.zsh')).toString()

const compiled = Handlebars.compile(template);


export const generate = (completionSpec: Schema): string => {
  const commandName = completionSpec.command;
  const subcommandsList = completionSpec.subcommands
    .filter(subcommand => subcommand.command !== "")
    .map(subcommand => subcommand.command)
    .join(' ');

  const subcommands = completionSpec.subcommands
    .map(subcommand => {
    const name = subcommand.command;

    const booleanFlags = subcommand.flags
      .filter(flag => flag.type === 'boolean')
      .map(flag => ({ longName: flag.name, shortName: flag.char }));
    const stringFlags = (subcommand.flags || [])
      .filter(flag => flag.type === 'string')
      .map(flag => {
        const result: any = { longName: flag.name, shortName: flag.char };
        result.completion = {};
        switch (flag.completion.type) {
          case 'files':
            result.completion.files = true;
            break;
          case 'directories':
            result.completion.directories = true;
            break;
          case 'oneOf':
            result.completion.oneOf = flag.completion.values.join(' ');
            break;
          case 'command':
            result.completion.command = flag.completion.command;
            result.completion.requiredCommands = flag.completion.requiredCommands;
            break;
        }

        return result;
      });

    const args = subcommand.args.map(arg => {
      const result: any = { completion: {} };
      switch (arg.completion.type) {
        case 'files':
          result.completion.files = true;
          break;
        case 'directories':
          result.completion.directories = true;
          break;
        case 'oneOf':
          result.completion.oneOf = arg.completion.values.join(' ');
          break;
        case 'command':
          result.completion.command = arg.completion.command;
          result.completion.requiredCommands = arg.completion.requiredCommands;
          break;
      }

      return result;
    });

    const hasFlags = booleanFlags.length > 0 || stringFlags.length > 0

    return { name, booleanFlags, stringFlags, args, hasFlags };
  });

  const rootCommandIndex = subcommands.findIndex(subcommand => subcommand.name === '')
  let rootCommand: typeof subcommands[0] | null = null
  if (rootCommandIndex !== -1) {
    rootCommand = subcommands[rootCommandIndex]
    subcommands.splice(rootCommandIndex, 1)
  }

  return compiled({ commandName, subcommandsList, subcommands, rootCommand });
};
