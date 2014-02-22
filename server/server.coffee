#!/usr/bin/env coffee
logger  = require('tracer').colorConsole()
restify = require 'restify'
connect = require 'connect'
fs      = require 'fs'
path    = require 'path'
eco     = require 'eco'
_       = require 'lodash'

config  = require './config.json'
runner  = require './runner.coffee'

# Root directory.
root = path.resolve __dirname, '../'

# The index template.
index = fs.readFileSync "#{root}/server/index.eco.html", 'utf8'

# The package.
{ name, version } = require "#{root}/package.json"

# Restify server config.
server = restify.createServer
    'name': 'im-runnable'
    'version': version or '0.0.0'

server.use do restify.bodyParser

# Get a list of environments available.
server.get '/api/languages', (req, res, next) ->
    res.send 'data': config.languages
    do next

# Run a script.
server.post '/api/run', (req, res, next) ->
    # TODO: Auth.
    token = req.headers?.authorization

    # Validate params.
    { cmd, src } = req.params
    unless cmd and src
        res.send new restify.MissingParameterError '`cmd` and `src` need to be provided'
        do next

    unless cmd in _.pluck config.languages, 'key'
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
.use((req, res, next) ->
    logger.log req.url

    switch req.url
        # Index page.
        when '/'
            res.end eco.render index,
                'host': req.headers.host
        # Pipe to restify.
        else
            server.server.emit 'request', req, res

# Connect listen.
).listen process.env.PORT or 5000

logger.info "#{name} started on port #{app.address().port}"