#!/usr/bin/env coffee
{ spawn } = require 'child_process'
path      = require 'path'

time = -> + new Date

a = do time

return unless process.argv.length is 4
[ lang, script ] = process.argv[2..3]

# Get the absolute path of the script.
script = path.resolve __dirname, script

# Run this script.
child = spawn 'bash', [ 'exec.sh', lang, script ]

# Debug the output.
child.stdout.on 'data', (data) ->
    try
        console.log JSON.stringify JSON.parse(data), null, 2
    catch
        console.log String data

# Trouble.
child.stderr.on 'data', (err) ->
    console.log String err
    process.exit 1

# How long did it take.
child.on 'close', (code) ->
    b = do time
    console.log '\nDone in', b - a, 'ms'