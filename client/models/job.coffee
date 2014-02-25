Job = can.Model.extend
    'findAll': ->
        $.ajax
            'url':         '/api/v1/jobs.json'
            'type':        'get'
            'dataType':    'json'
            'contentType': 'application/json'
    
    'findOne': ->
        $.ajax
            'url':         '/api/v1/jobs/455454.json'
            'type':        'get'
            'dataType':    'json'
            'contentType': 'application/json'
    
    'create': (data) ->
        $.ajax
            'url':         '/api/v1/jobs.json'
            'type':        'post'
            'dataType':    'json'
            'contentType': 'application/json'
            'data':        JSON.stringify data

    'destroy': ->
        $.ajax
            'url':         '/api/v1/jobs/455454.json'
            'type':        'delete'
            'dataType':    'json'
            'contentType': 'application/json'

, {}

module.exports = (data) ->
    # TODO keep latest results state in its own model.
    # TODO say we are running and switch to results tab.
    
    # TODO destroy any existing todo on the server.
    
    # TODO send the data.
    # TOOD keep polling until we get status 'fińished' or we get a 404. If someone else destroys us, we will 404 here.