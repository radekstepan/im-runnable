#!/usr/bin/env coffee
{ spawn } = require 'child_process'

# Run a command.
module.exports = ({ src, cmd }, cb) ->
    # Run this script.
    child = spawn 'bash', [ "#{__dirname}/run.sh", src, cmd ]

    res =
        'stdout': []
        'stderr': []

    # Debug the output.
    child.stdout.on 'data', (out) ->
        res.stdout.push String out

    # Trouble.
    child.stderr.on 'data', (out) ->
        res.stderr.push String out

    # Call back.
    child.on 'close', (code) ->
        cb null, res