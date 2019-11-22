import * as fs from 'fs'
import * as path from 'path'
import Handlebars from 'handlebars'
import { Schema } from '@completely/spec'

Handlebars.registerHelper('commandsExist', (commands: string[]) => {
  if (!commands || !commands.length) {
    return 'true'
  }
  const commandsConditions = commands.map(command => `command -v ${command} > /dev/null`)

  const condition = commandsConditions.join(' && ')

  return condition
})

const template = fs.readFileSync(path.join(__dirname, 'template.sh')).toString()

const compiled = Handlebars.compile(template)

type Completion = Schema['subcommands'][0]['flags'][0]['completion']

const buildCompletion = (completion: Completion) => {
  const result: any = {}
  if (!completion) {
    return result
  }
  switch (completion.type) {
    case 'files':
      result.files = true
      break
    case 'directories':
      result.directories = true
      break
    case 'oneOf':
      result.oneOf = completion.values.join(' ')
      break
    case 'command':
      result.command = completion.command
      result.requiredCommands = completion.requiredCommands
      break
  }

  return result
}

export const generate = (completionSpec: Schema): string => {
  const commandName = completionSpec.command
  const subcommandsList = completionSpec.subcommands
    .filter(subcommand => subcommand.command !== '')
    .map(subcommand => subcommand.command)
    .join(' ')

  const subcommands = completionSpec.subcommands.map(subcommand => {
    const name = subcommand.command

    const flags = subcommand.flags
      .map(flag => ({ ...flag, longName: flag.name, shortName: flag.char }))
      .map(flag => {
        if (flag.type === 'string') {
          const result = {
            ...flag,
            completion: buildCompletion(flag.completion)
          }

          return result
        }

        return flag
      })

    const stringFlags = flags.filter(flag => flag.type === 'string')
    const booleanFlags = flags.filter(flag => flag.type === 'boolean')

    const args = subcommand.args.map(arg => {
      const result = {
        completion: buildCompletion(arg.completion)
      }

      return result
    })

    return {
      name,
      booleanFlags,
      stringFlags,
      args,
      isRootCommand: name === '',
      allFlags: booleanFlags.concat(stringFlags)
    }
  })

  return compiled({ commandName, subcommandsList, subcommands })
}
