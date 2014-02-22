languages = require '../models/languages'
config    = require '../models/config'

_.find languages, (lang) ->
    return unless config.default_language is lang.key
    lang.active = yes

# Listify.
languages = new can.List languages

# Are we expanded?
expanded = can.compute no

module.exports = can.Component.extend

    tag: 'app-select'

    template: require '../templates/select'

    scope: (obj, parent, el) ->
        {
            languages,
            'expanded':
                'value': expanded
            'select': (obj) ->
                ( lang.attr 'active', no for lang in languages )
                { key, label } = do obj.attr
                obj.attr 'active', yes

                # Close dropdown.
                expanded no
        }

    events:
        # Toggle our expanded state.
        '.field click': (el, evt) ->
            expanded b = not do expanded
            do @element.find('.search .input').focus if b