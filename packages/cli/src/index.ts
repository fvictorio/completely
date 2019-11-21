import betterAjvErrors from 'better-ajv-errors'
import * as fs from 'fs'
import { generate as generateBash } from '@completely/bash-generator'
import { generate as generateZsh } from '@completely/zsh-generator'
import { Command, flags } from '@oclif/command'
import { schema, validate } from '@completely/spec'

class Completely extends Command {
  static description = 'Generate a shell completion script from a JSON description of your command'

  static flags = {
    version: flags.version({ char: 'v' }),
    help: flags.help({ char: 'h' }),
    shell: flags.string({
      description: 'Choose a shell for generating the completion file',
      options: ['bash', 'zsh'],
      default: 'bash'
    })
  }

  static args = [{ name: 'file' }]

  async run() {
    const { args, flags } = this.parse(Completely)

    const { shell } = flags

    let completionSpec
    try {
      completionSpec = JSON.parse(fs.readFileSync(args.file).toString())
    } catch (e) {
      this.error('The specified file is not a valid JSON')
    }

    const valid = validate(completionSpec)
    if (!valid) {
      const output = betterAjvErrors(schema, completionSpec, validate.errors, { indent: 2 })
      this.error(output as any)
    }

    let script: string = ''
    if (shell === 'bash') {
      script = generateBash(completionSpec)
    } else if (shell === 'zsh') {
      script = generateZsh(completionSpec)
    } else {
      this.error(`Unsupported shell: '${shell}'`)
    }

    this.log(script)
  }
}

export = Completely
