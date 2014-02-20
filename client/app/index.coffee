render = require './modules/render'

layout = require './templates/layout'

components = [

]

module.exports = (opts) ->
    # Load the components.
    ( require "./components/#{name}" for name in components )

    # Setup the UI.
    $(opts.el).html render layout

    # Setup the editor.
    CodeMirror $('#editor .input')[0],
        'value':      'function myScript(){ return 100; }',
        'mode':       'javascript'
        'theme':      'jsbin'
        'lineNumbers': yes