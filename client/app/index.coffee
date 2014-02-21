render = require './modules/render'

layout = require './templates/layout'

components = [
    'select'
]

module.exports = (opts) ->
    # Load the components.
    ( require "./components/#{name}" for name in components )

    # Setup the UI.
    $(opts.el).html render layout

    # Setup the editor.
    CodeMirror $('#editor .content').get(0),
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

    # Reposition sidebar on scroll.
    do ->
        height = do $('#nav').outerHeight
        sidebar = $('#sidebar ul')
        $(document).on 'scroll', ->
            sidebar.css 'margin-top', Math.max 0, height - do $(window).scrollTop