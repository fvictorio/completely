import * as fs from 'fs'
import * as path from 'path'
import Handlebars from 'handlebars';

const template = fs.readFileSync(path.join(__dirname, 'template.sh')).toString()

const compiled = Handlebars.compile(template);

export const generate = (completionSpec: any): string => {
  const commandName = completionSpec.command;
  const subcommandsList = completionSpec.subcommands
    .map((subcommand: any) => subcommand.name)
    .join(' ');
  const subcommands = completionSpec.subcommands.map((subcommand: any) => {
    const name = subcommand.name;

    const booleanFlags = (subcommand.flags || [])
      .filter((flag: any) => flag.type === 'boolean')
      .map((flag: any) => ({ longName: flag.name }));
    const stringFlags = (subcommand.flags || [])
      .filter((flag: any) => flag.type === 'string')
      .map((flag: any) => {
        const completionFiles = flag.completion.type === 'files';
        const completionDirectories = flag.completion.type === 'directories';
        const completionOneOf = flag.completion.type === 'oneOf';

        const result: any = { longName: flag.name };
        result.completion = {};
        if (completionFiles) {
          result.completion.files = true;
        } else if (completionDirectories) {
          result.completion.directories = true;
        } else if (completionOneOf) {
          result.completion.oneOf = flag.completion.values.join(' ');
        }

        return result;
      });

    const args = (subcommand.args || []).map((arg: any) => {
      const completionFiles = arg.completion.type === 'files';
      const completionDirectories = arg.completion.type === 'directories';

      const result: any = { completion: {} };
      if (completionFiles) {
        result.completion.files = true;
      } else if (completionDirectories) {
        result.completion.directories = true;
      }

      return result;
    });

    return { name, booleanFlags, stringFlags, args };
  });

  return compiled({ commandName, subcommandsList, subcommands });
};
