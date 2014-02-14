moment    = require 'moment'
fs        = require 'fs'
{ spawn } = require 'child_process'

start = moment()

child = spawn "bash", [ 'exec.sh' ]

child.stdout.on 'data', (data) ->
    try
        console.log JSON.stringify JSON.parse(data), null, 2
    catch
        console.log new String data

child.stderr.on 'data', (err) ->
    throw err

child.on 'close', (code) ->
    console.log 'Done in', moment().diff(start), 'ms'