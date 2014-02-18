#!/usr/bin/env coffee
logger  = require('tracer').colorConsole()
restify = require 'restify'
connect = require 'connect'
path    = require 'path'
runner  = require './runner'

# Root directory.
root = path.resolve __dirname, '../'

{ name, version } = require "#{root}/package.json"

# Restify server config.
server = restify.createServer
    'name': 'im-runnable'
    'version': version or '0.0.0'

server.use do restify.bodyParser

# Run a script.
server.post '/api/run', (req, res, next) ->
    # Auth.
    token = req.headers?.authorization
    # Run it and get the res.
    runner req.params, (out) ->
        res.send out
        do next

app = connect()
# Serve the public dir.
.use(connect.static("#{root}/public"))
# Pipe to restify.
.use((req, res, next) ->
    server.server.emit 'request', req, res
# Connect listen.
).listen process.env.PORT or 5000

logger.log "#{name} started on port #{app.address().port}"