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

        # Is the script running atmo?
        isRunning: (opts) ->
            if (status = job.attr('status')) and status is 'running'
                opts.fn(@)
            else
                opts.inverse(@)

        # Format a line from a terminal.
        format: (line) ->
            # JSON?
            try
                obj = JSON.parse line
                # Will be syntax highlighted.
                line = hljs.highlight('javascript', JSON.stringify(obj, null, 2)).value

            # Just standard log.
            "<pre>#{line}</pre>"