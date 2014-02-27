job = require '../models/job'

module.exports = can.Component.extend

    tag: 'app-results'

    template: require '../templates/results'

    scope: (obj, parent, el) ->
        { job }

    helpers:
        # Is terminal output empty?
        isEmpty: (opts) ->
            return unless out = job.attr('out')
            if out.stdout.length + out.stderr.length
                opts.inverse(@)
            else
                opts.fn(@)