render = require './modules/render'

layout = require './templates/layout'

components = [
    'editor'
    'select'
]

module.exports = (opts) ->
    # Load the components.
    ( require "./components/#{name}" for name in components )

    # Setup the UI.
    $(opts.el).html render layout

    # Reposition sidebar on scroll.
    do ->
        height = do $('#nav').outerHeight
        sidebar = $('#sidebar ul')
        $(document).on 'scroll', ->
            sidebar.css 'margin-top', Math.max 0, height - do $(window).scrollTop