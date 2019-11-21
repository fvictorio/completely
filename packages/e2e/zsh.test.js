const fs = require('fs')
var pty = require('node-pty')
const stripAnsi = require('strip-ansi');

const CTRL_U = '\x15'
const TAB = '\x09'

var shell = 'zsh'

const fixtures = [
  ['oneArgOneFlag ', 'oneArgOneFlag \nbar  baz  foo  qux'],
  ['oneArgOneFlag b', 'oneArgOneFlag ba'],
  ['oneArgOneFlag f', 'oneArgOneFlag foo '],
  ['oneArgOneFlag q', 'oneArgOneFlag qux '],
  ['oneArgOneFlag z', 'oneArgOneFlag z'],
  ['oneArgOneFlag -', 'oneArgOneFlag --myflag '],
  ['oneArgOneFlag --myflag -', 'oneArgOneFlag --myflag -'],

  ['twoSubcommands ', 'twoSubcommands \nbar  foo'],
  ['twoSubcommands f', 'twoSubcommands foo '],
  ['twoSubcommands b', 'twoSubcommands bar '],
  ['twoSubcommands z', 'twoSubcommands z'],
  ['twoSubcommands foo -', 'twoSubcommands foo --flag '],
  ['twoSubcommands foo --flag ', 'twoSubcommands foo --flag \ncompletions/   node_modules/'],
]

for (const [prefix, expected] of fixtures) {
  test(prefix, async () => {
    const rawOutput = await getRawOutput(prefix)
    const strippedOutput = stripAnsi(rawOutput).replace(/\x07/g, '').replace(/\r/g, '')
    fs.writeFileSync('debug.txt', strippedOutput)
    expect(strippedOutput).toEqual(expected)
  })
}

const getRawOutput = prefix => {
  return new Promise(resolve => {
    var ptyProcess = pty.spawn(shell, ['-i', '-d', '-f'], {
      name: 'xterm-mono',
      cols: 80,
      rows: 30,
      cwd: process.cwd(),
      env: { PROMPT: '$ ' },
      handleFlowControl: true
    })

    let output = ''
    let saveOutput = false
    ptyProcess.on('data', function(data) {
      if (!saveOutput) return
      output += data
    })

    ptyProcess.write('fpath=(./completions $fpath)\r')
    ptyProcess.write('autoload -U compinit && compinit\r')
    setTimeout(() => {
      saveOutput = true
      ptyProcess.write(prefix)
      ptyProcess.write(TAB)

      setTimeout(() => {
        saveOutput = false
        ptyProcess.write(CTRL_U)
        ptyProcess.write('exit\r')
      }, 100)
    }, 100)

    ptyProcess.on('exit', () => {
      resolve(output.split('\x1b\x5b\x41')[0].split('\x08')[1])
    })
  })
}
