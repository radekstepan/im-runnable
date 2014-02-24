db = require '../models/db'

# The CodeMirror object.
editor = null

# Update editor syntax highlighting when the language changes.
db.bind 'language', (obj, newVal) ->
    editor.setOption 'mode', newVal

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
        # Run.
        '.btn.run click': ->
            $.ajax('/api/jobs',
                'contentType' : 'application/json'
                'type' : 'POST'
                'data': JSON.stringify
                    'src':  do editor.getValue
                    'lang': editor.getOption('mode')
            ).done( (res) ->
                console.log res.data.id
            ).fail (err) ->
                throw err

        inserted: (el) ->
            # Setup the editor.
            editor = CodeMirror el.find('.content').get(0),
                # Language mode.
                'mode': db.attr('language')
                # Current theme.
                'theme': 'github'
                # Show line numbers.
                'lineNumbers': yes
                # Be able to search the whole shebang.
                'viewportMargin': Infinity
                # Show cursor when selecting...
                'showCursorWhenSelecting': yes
                # Line wrap.
                'lineWrapping': true
                # Example script (js).
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