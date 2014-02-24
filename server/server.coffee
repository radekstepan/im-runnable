#!/usr/bin/env coffee
logger   = require('tracer').colorConsole()
flatiron = require 'flatiron'
director = require 'director'
connect  = require 'connect'
fs       = require 'fs'
path     = require 'path'
eco      = require 'eco'
_        = require 'lodash'

config   = require './config.json'

# Start the queue.
queue    = require('./queue.coffee') config.queue

# Root directory.
root = path.resolve __dirname, '../'

# The index template.
index = fs.readFileSync "#{root}/server/index.eco.html", 'utf8'

# The package.
{ name, version } = require "#{root}/package.json"

# Flatiron app.
{ app } = flatiron
app.use flatiron.plugins.http,
    # Headers.
    'headers':
        'X-Powered-By': "#{name} v#{version}"
    
    # Custom middleware.
    'before': [
        # Log all requests.
        (req, res, next) ->
            logger.log req.url
            do next
        
        # Support trailing slash, multiple res types, default version for api.
        (req, res, next) ->
            req.url = req.url.replace /^\/api\/(.*)\/$/,      '/api/$1'    # slash
            req.url = req.url.replace /^\/api\/(.*)\.json$/,  '/api/$1'    # json
            req.url = req.url.replace /^\/api\/(?!v\d+)(.*)/, '/api/v1/$1' # version
            do next

        # Serve the index page.
        (req, res, next) ->
            if req.url is '/'
                res.end eco.render index,
                    'host': req.headers.host
            do next

        # Serve the public dir.
        connect.static("#{root}/public")
    ]

# Response handler.
res = (obj, code=200) ->
    @res.writeHead code, 'Content-Type': 'application/json'
    @res.write JSON.stringify obj
    do @res.end

# The api router.
app.router = new director.http.Router
    '/api':
        '/v1':
            '/languages':
                # Get a list of environments available.
                get: ->
                    res.call @, { 'data': config.languages }
            
            '/jobs':
                # Submit a job to run a script.
                post: ->
                    { lang, src } = @req.body

                    # Missing params?
                    unless lang and src
                        return res.call @, { 'message': 'Missing parameters, you need to provide: lang, src' }, 400

                    # Unknown language?
                    unless lang in _.pluck config.languages, 'key'
                        return res.call @, { 'message': "Platform not supported: #{lang}" }, 400

                    # Form the command.
                    { cmd } = _.find config.languages, { 'key': lang }

                    # Add a job to the queue & get its id.
                    id = queue.push { cmd, src }
                    
                    res.call @, { 'data': { id, cmd } }, 201

# # Retrieve the results of a job.
# server.get '/api/job/:id', (req, res, next) ->    
#     # No job.
#     unless job = queue.get req.params.id
#         res.send new restify.ResourceNotFoundError()
#     else
#         if job.err
#             res.send new restify.InternalError err
#         else
#             # Remove error code.
#             delete job.err
#             # And send the results.
#             res.send 'data': job
    
#     do next

# # Delete a job.
# server.del '/api/job/:id', (req, res, next) ->
#     queue.delete req.params.id
#     # Success, no content.
#     res.status 204
#     do res.send
#     do next

# Listen.
app.listen process.env.PORT or 5000, ->
    { port } = app.server.address()
    logger.info "#{name} started on port #{port}"