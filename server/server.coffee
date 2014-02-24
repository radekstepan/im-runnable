#!/usr/bin/env coffee
logger  = require('tracer').colorConsole()
restify = require 'restify'
connect = require 'connect'
fs      = require 'fs'
path    = require 'path'
eco     = require 'eco'
_       = require 'lodash'

config  = require './config.json'

# Start the queue.
queue   = require('./queue.coffee') config.queue

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

# Submit a job to run a script.
server.post '/api/job', (req, res, next) ->
    # TODO: Auth.
    token = req.headers?.authorization

    # Validate params.
    { lang, src } = req.params
    unless lang and src
        res.send new restify.MissingParameterError '`lang` and `src` need to be provided'
        do next

    unless lang in _.pluck config.languages, 'key'
        res.send new restify.InvalidArgumentError "#{lang} is not supported"
        do next

    # Form the command.
    { cmd } = _.find config.languages, { 'key': lang }

    # Add a job to the queue & get its id.
    id = queue.push { cmd, src }
    # Return and say we are processing.
    res.status 202
    res.send 'data': { id }
    do next

# Retrieve the results of a job.
server.get '/api/job/:id', (req, res, next) ->    
    # No job.
    unless job = queue.get req.params.id
        res.send new restify.ResourceNotFoundError()
    else
        if job.err
            res.send new restify.InternalError err
        else
            # Remove error code.
            delete job.err
            # And send the results.
            res.send 'data': job
    
    do next

# Delete a job.
server.del '/api/job/:id', (req, res, next) ->
    queue.delete req.params.id
    # Success, no content.
    res.status 204
    do res.send
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