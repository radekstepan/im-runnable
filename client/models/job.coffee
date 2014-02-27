# Singleton Job instance. Submit a job to get its `id` back which is
#  observed. Polling will update our data which is observed as well.
module.exports = job = new can.Map

    # Changing this attr will trigger poll until we get `out` back.
    id: null

    submit: (obj) ->
        $.ajax({
            'url':         '/api/v1/jobs.json'
            'type':        'post'
            'dataType':    'json'
            'contentType': 'application/json'
            'data':        JSON.stringify obj
        }).then ({ data }) =>
            # Save the new id.
            @attr 'id', data.id
    
    # Get the latest data for a job with an optional done cb.
    get: _.debounce (done) ->
        $.ajax({
            'url':         "/api/v1/jobs/#{@attr('id')}.json"
            'type':        'get'
            'dataType':    'json'
            'contentType': 'application/json'
        }).then ({ data }) =>
            @attr data, no # do not override existing
            do done if _.isFunction done
    , 500

    destroy: (id) ->
        $.ajax
            'url':         "/api/v1/jobs/#{id}.json"
            'type':        'delete'
            'dataType':    'json'
            'contentType': 'application/json'

# Keep polling for latest data when our id changes.
job.bind 'id', (ev, newId, oldId) ->
    # Clear the previous job if it exists.
    job.destroy oldId if oldId

    # Destroy `out`.
    @removeAttr 'out'

    # Get the latest data...
    do get = ->
        # ...until we get results.
        return if job.attr 'out'
        # ...or we are old news.
        return if newId isnt job.attr('id')
        # And call again.
        job.get get