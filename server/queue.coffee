uuid      = require 'node-uuid'
{ queue } = require 'async'
_         = require 'lodash'

runner    = require './runner.coffee'

module.exports = (opts) ->
    # Create the queue.
    q = queue runner, opts.concurrency

    # The results map.
    results = {}

    # Add a job to the queue & run it.
    fn =
        push: (job) ->
            # Generate the id of the job.
            id = do uuid.v4

            # Add the job into results as running.
            results[id] = { 'status': 'running' }

            # We are clearing you after this amount of time.
            setTimeout _.partial(fn.delete, id), opts.timeout

            # Push the job to the queue.
            q.push job, (err, out) ->
                # Skip if job got deleted and we have not responded yet.
                return unless id of results
                # Add the result to the results map.
                results[id] = { 'status': 'done', err, out }

            # Return the id to the user.
            id

        # Get the job results.
        get: (id) ->
            delete results[id] if job = results[id] # remove too
            job

        # Delete a job.
        delete: (id) -> delete results[id]