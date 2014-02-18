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
    # TODO: Auth.
    token = req.headers?.authorization

    # Validate params.
    { cmd, src } = req.params
    unless cmd and src
        res.send new restify.MissingParameterError '`cmd` and `src` need to be provided'
        do next

    unless cmd in [ 'node', 'ruby' ]
        res.send new restify.InvalidArgumentError "#{cmd} is not supported"
        do next

    # Run it and get the output.
    runner { cmd, src }, (err, out) ->
        if err
            res.send new restify.InternalError err
        else
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