import * as fs from 'fs'
import * as path from 'path'
import Handlebars from 'handlebars'
import { Schema } from '@completely/spec'

Handlebars.registerHelper('add', (x: string, y: string) => {
  return String(+x + +y)
})

Handlebars.registerHelper('stringFlag', (flag: any) => {
  return [
    flag.multiple ? '\\*' : '',
    `"--${flag.longName}: :`,
    !flag.completion ? '' : flag.completion.directories ? '_dirs' : flag.completion.oneOf ? `(${flag.completion.oneOf})` : '_files',
    ,
    '" '
  ].join('')
})

const template = fs.readFileSync(path.join(__dirname, 'template.zsh')).toString()

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
      const result = { completion: buildCompletion(arg.completion) }

      return result
    })

    const hasFlags = booleanFlags.length > 0 || stringFlags.length > 0

    return {
      name,
      booleanFlags,
      stringFlags,
      args,
      hasFlags,
      allFlags: booleanFlags.concat(stringFlags)
    }
  })

  const rootCommandIndex = subcommands.findIndex(subcommand => subcommand.name === '')
  let rootCommand: typeof subcommands[0] | null = null
  if (rootCommandIndex !== -1) {
    rootCommand = subcommands[rootCommandIndex]
    subcommands.splice(rootCommandIndex, 1)
  }

  return compiled({ commandName, subcommandsList, subcommands, rootCommand })
}
