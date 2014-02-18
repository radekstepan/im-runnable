#!/usr/bin/env coffee
{ spawn } = require 'child_process'

# Get the current time.
time = -> + new Date

# Run a command.
module.exports = ({ src, cmd }, cb) ->
    # Start the clock.
    start = do time

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

    # How long did it take.
    child.on 'close', (code) ->
        res.ms = do time - start
        cb res