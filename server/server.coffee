#!/usr/bin/env coffee
logger  = require('tracer').colorConsole()
restify = require 'restify'
connect = require 'connect'
path    = require 'path'

# Root directory.
root = path.resolve __dirname, '../'

{ name, version } = require "#{root}/package.json"

# Restify server config.
server = restify.createServer
    'name': 'im-runnable'
    'version': version or '0.0.0'
 
server.get '/api/run', (req, res, next) ->
    res.send req.params
    do next

app = connect()
# Serve the public dir.
.use(connect.static("#{root}/public"))
# Pipe to restify.
.use((req, res, next) ->
    if req.url.match /^\/api/
        server.server.emit 'request', req, res
    else
        do next
# Connect listen.
).listen process.env.PORT or 5000

logger.log "#{name} started on port #{app.address().port}"