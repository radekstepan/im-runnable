#!/usr/bin/env coffee
logger    = require('tracer').colorConsole()
uuid      = require 'node-uuid'
{ queue } = require 'async'
_         = require 'lodash'

runner    = require './runner.coffee'

# Get the current time.
time = -> + new Date

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

            # Log it.
            logger.log "Job #{id} queued"
            start = do time

            # Add the job into results as running.
            results[id] = { 'status': 'running' }

            # We are clearing you after this amount of time.
            setTimeout _.partial(fn.delete, id), opts.timeout

            # Push the job to the queue.
            q.push job, (err, out) ->
                # Skip if job got deleted and we have not responded yet.
                return unless id of results
                
                # Log it.
                logger.log "Job #{id} finished"
                ms = do time - start

                # Add the result to the results map.
                results[id] = { 'status': 'done', err, out, ms }

            # Return the id to the user.
            id

        # Get the job results.
        get: (id) ->
            job = results[id]
            # Delete if finished too.
            delete results[id] if job.status is 'done'
            job

        # Delete a job.
        delete: (id) -> delete results[id]