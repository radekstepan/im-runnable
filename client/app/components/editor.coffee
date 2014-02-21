editor = null

# Cursor position.
cursor = new can.Map
    'line': 1
    'ch':   1

module.exports = can.Component.extend

    tag: 'app-editor'

    template: require '../templates/editor'

    scope: (obj, parent, el) ->
        { cursor }

    events:
        inserted: (el) ->
            # Setup the editor.
            editor = CodeMirror el.find('.content').get(0),
                'mode':           'javascript'
                'theme':          'github'
                'lineNumbers':    yes
                'viewportMargin': +Infinity
                'value': """
                    // Require the Request library.
                    var req = require('request');

                    // Search against FlyMine.
                    req({
                        'uri': 'http://www.flymine.org/query/service/search',
                        // For terms associated with "micklem".
                        'qs': { 'q': "micklem" }
                    }, function(err, res) {
                        if (err) throw err;

                        // Just log it.
                        console.log(res.body);
                    });
                """

            # Listen to editor events.
            editor.on 'cursorActivity', (instance) ->
                # Line & column numbers are 0-indexed.
                cursor.attr _.transform( do editor.getCursor, (res, val, key) ->
                    res[key] = val + 1
                ), yes