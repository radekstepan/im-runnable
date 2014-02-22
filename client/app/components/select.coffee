languages = new can.List require '../models/languages'
config    = require '../models/config'

for lang in languages
    # Set the default language.
    lang.attr 'active', yes if config.default_language is lang.attr 'key'
    # Show us all.
    lang.attr 'show', yes

# Current query filter.
query = can.compute ''

# Filter the languages on query.
query.bind 'change', (ev, newVal, oldVal) ->
    # Empty = no filter.
    return (lang.attr('show', yes) for lang in languages) unless newVal.length

    # RegExp match.
    re = new RegExp "#{newVal}.*", 'i'
    ( lang.attr('show', lang.attr('label').match re) for lang in languages )

# Are we expanded?
expanded = can.compute no

# Reset filter if we are closing the dropdown.
expanded.bind 'change', (ev, newVal, oldVal) ->
    query '' if newVal?

# The select field UI element.
module.exports = can.Component.extend

    tag: 'app-select'

    template: require '../templates/select'

    scope: (obj, parent, el) ->
        {
            languages,
            'query':
                'value': query
            'expanded':
                'value': expanded
            'select': (obj) ->
                # Reset all.
                ( lang.attr 'active', no for lang in languages )
                # Get the current one.
                { key, label } = do obj.attr
                # Activate.
                obj.attr 'active', yes
                # Close dropdown.
                expanded no
        }

    events:
        # Toggle our expanded state.
        '.field click': (el, evt) ->
            expanded b = not do expanded
            do @element.find('.search .input').focus if b

        # Filter the dropdown.
        '.search .input keyup': (el, evt) ->
            switch evt.which
                # Escape.
                when 27 then return expanded no
                # Set the new query.
                else query el.val().toLowerCase().replace /[^a-z]*/g, ''

        # Start watching if we click outside of us.
        'inserted': (el) ->
            $(document).on 'click', (evt) ->
                expanded no unless el.is(evt.target) or el.has(evt.target).length

    helpers:
        # Display a label. Used when we have a regex on us.
        display: (val, opts) ->
            val().replace new RegExp("(#{query()})", 'ig'), "<span>$1</span>"