job = require '../models/job'

module.exports = can.Component.extend

    tag: 'app-results'

    template: require '../templates/results'

    scope: (obj, parent, el) ->
        { job }

    helpers: {}