#!/usr/bin/env coffee
uuid      = require 'node-uuid'
{ queue } = require 'async'
_         = require 'lodash'

runner    = require './runner.coffee'

# Get the current time.
time = (offset=0) ->
    do new Date(+ new Date + offset).toISOString

module.exports = (opts) ->
    # The jobs map.
    jobs = {}
    
    # Create the queue.
    q = queue (job, done) ->
        # Maybe we have timed out.
        return do done unless ref = jobs[job.id]
        # Job started.
        ref.started_at = do time
        ref.status = 'running'
        
        # Actually run.
        runner job, (err, out) ->
            # Maybe we have timed out.
            return do done unless ref

            # Job finished.
            ref.finished_at = do time
            ref.status = 'finished'
            ref.out = out
            # Trouble?
            ref.err = err if err

            do done

    # How many at a time?
    , opts.concurrency

    # Add a job to the queue & run it.
    fn =
        push: (job) ->
            # Generate the id of the job.
            job.id = id = do uuid.v4

            # Save the job.
            jobs[job.id] =
                'status':     'queued'
                'id':         id
                'created_at': do time
                'expires_at': time opts.timeout

            # We are clearing you after this amount of time.
            setTimeout _.partial(fn.delete, id), opts.timeout

            # Push the job to the queue. It needs a callback...
            q.push job, ->

            # Return the id to the user.
            id

        # Get the job results.
        get: (id) ->
            return jobs[id] if id
            # TODO filter down to jobs that we have access to.
            _.values jobs

        # Delete a job.
        delete: (id) -> delete jobs[id]
