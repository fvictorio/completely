import * as fs from 'fs'
import { generate } from '@completely/bash-generator'
import {Command, flags} from '@oclif/command'

class Completely extends Command {
  static description = 'Generate a shell completion script from a JSON description of your command'

  static flags = {
    // add --version flag to show CLI version
    version: flags.version({char: 'v'}),
    help: flags.help({char: 'h'}),
    // flag with a value (-n, --name=VALUE)
    name: flags.string({char: 'n', description: 'name to print'}),
    // flag with no value (-f, --force)
    force: flags.boolean({char: 'f'}),
  }

  static args = [{name: 'file'}]

  async run() {
    const {args, flags} = this.parse(Completely)

    const completionSpec = JSON.parse(fs.readFileSync(args.file).toString())

    const script = generate(completionSpec)

    this.log(script)
  }
}

export = Completely
