import * as fs from 'fs'
import * as path from 'path'
import Handlebars from 'handlebars';

Handlebars.registerHelper('commandsExist', (commands: string[]) => {
  if (!commands || !commands.length) {
    return 'true'
  }
  const commandsConditions = commands
    .map(command => `command -v ${command} > /dev/null`)

  const condition = commandsConditions.join(' && ')

  return condition
})

const template = fs.readFileSync(path.join(__dirname, 'template.sh')).toString()

const compiled = Handlebars.compile(template);


export const generate = (completionSpec: any): string => {
  const commandName = completionSpec.command;
  const subcommandsList = (completionSpec.subcommands || [])
    .map((subcommand: any) => subcommand.name)
    .join(' ');

  const rootCommand = {
    ...completionSpec,
    name: "",
    subcommands: null
  }

  const allCommands = completionSpec.subcommands ? (completionSpec.subcommands || []) : [rootCommand]

  const subcommands = allCommands.map((subcommand: any) => {
    const name = subcommand.name;

    const booleanFlags = (subcommand.flags || [])
      .filter((flag: any) => flag.type === 'boolean')
      .map((flag: any) => ({ longName: flag.name, shortName: flag.char }));
    const stringFlags = (subcommand.flags || [])
      .filter((flag: any) => flag.type === 'string')
      .map((flag: any) => {
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

    const args = (subcommand.args || []).map((arg: any) => {
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

    return { name, booleanFlags, stringFlags, args };
  });

  return compiled({ commandName, subcommandsList, subcommands });
};
