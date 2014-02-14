{ spawn } = require 'child_process'

time = -> + new Date

a = do time

# Run this script.
return unless script = process.argv[2]
child = spawn 'bash', [ 'exec.sh', script ]

# Debug the output.
child.stdout.on 'data', (data) ->
    try
        console.log JSON.stringify JSON.parse(data), null, 2
    catch
        console.log new String data

# Trouble.
child.stderr.on 'data', (err) ->
    throw err

# How long did it take.
child.on 'close', (code) ->
    b = do time
    console.log '\nDone in', b - a, 'ms'