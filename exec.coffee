Sandbox = require 'sandbox'
eco     = require 'eco'
fs      = require 'fs'

which = 'resolve-ids'

fs.readFile './env.eco.js', 'utf8', (err, env) ->
    throw err if err

    fs.readFile "./scripts/#{which}.js", 'utf8', (err, script) ->
        throw err if err

        try
            fn = eco.precompile env
        catch err
            throw err

        js = eco.render env, { script }

        box = new Sandbox()
        box.run js, (output) ->
            console.log JSON.stringify output, null, 4