#!/usr/bin/env coffee
logger   = require('tracer').colorConsole()
flatiron = require 'flatiron'
director = require 'director'
connect  = require 'connect'
fs       = require 'fs'
path     = require 'path'
eco      = require 'eco'
_        = require 'lodash'

config   = require './config.coffee'

# Start the queue.
queue    = require('./queue.coffee') config.queue

# Root directory.
root = path.resolve __dirname, '../'

# The index template.
index = fs.readFileSync "#{root}/server/index.eco.html", 'utf8'

# The package.
{ name, version } = require "#{root}/package.json"

# Response handler.
respond = (obj, status=200) ->
    # Suppress response codes?
    obj.response_code = status
    if @req.query.suppress_response_codes in [ 'true', 'yes' ]
        status = 200

    @res.writeHead status, 'Content-Type': 'application/json'
    if _.keys(obj).length
        @res.write JSON.stringify obj
    else
        do @res.write # empty response for 204
    do @res.end

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

    # Handle errors.
    'onError': (err, req, res) ->
        respond.call { req, res }, { 'message': err.message }, err.status

# The api router.
app.router = new director.http.Router
    '/api':
        '/v1':
            '/languages':
                # Get a list of environments available.
                get: ->
                    respond.call @, { 'data': config.languages }
            
            '/jobs':
                # Submit a job to run a script.
                post: ->
                    { lang, src } = @req.body

                    # Missing params?
                    unless lang and src
                        return respond.call @, { 'message': 'Missing parameters, you need to provide: lang, src' }, 400

                    # Unknown language?
                    unless lang in _.pluck config.languages, 'key'
                        return respond.call @, { 'message': "Platform not supported: #{lang}" }, 400

                    # Form the command.
                    { cmd } = _.find config.languages, { 'key': lang }

                    # Add a job to the queue & get its id.
                    id = queue.push { cmd, src }
                    
                    respond.call @, { 'data': { id, cmd } }, 201

                # Get all of the jobs for a user.
                get: ->
                    respond.call @, { 'data': do queue.get }

                # Retrieve the results of a job.
                '/:id':
                    get: (id) ->
                        if data = queue.get id
                            respond.call @, { data }
                        else
                            respond.call @, { 'message': 'Not found' }, 404

                    delete: (id) ->
                        if queue.delete id
                            respond.call @, { }, 204
                        else
                            respond.call @, { 'message': 'Not found' }, 404

# Listen.
app.listen process.env.PORT or 5000, ->
    { port } = app.server.address()
    logger.info "#{name} started on port #{port}"