#!/usr/bin/env coffee
fs      = require 'fs'
restify = require 'restify'

fs.readFile __dirname + '/scripts/search.js', 'utf8', (err, script) ->
    throw err if err

    client = restify.createJsonClient
        'url':     'http://0.0.0.0:5000'
        'version': '*'
        'headers':
            'Authorization': 'token 123456'

    client.post '/api/run',
        'cmd': 'node'
        'src': script
    , (err, req, res, body) ->
        console.log JSON.stringify JSON.parse(body.stdout.join('\n')), null, 2
        process.exit err