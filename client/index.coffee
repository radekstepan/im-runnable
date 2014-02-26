render = require './modules/render'
layout = require './templates/layout'

components = [
    'tabs'
    'editor'
    'results'
    'select'
]

module.exports = (opts) ->
    # Load the components.
    ( require "./components/#{name}" for name in components )

    # Setup the UI.
    (el = $(opts.el)).html render layout

    # Reposition sidebar on scroll.
    do ->
        height = do $('#nav').outerHeight
        sidebar = $('#sidebar')
        $(document).on 'scroll', ->
            sidebar.css 'top', Math.max -height, - do $(window).scrollTop