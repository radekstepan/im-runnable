db        = require '../models/db'
languages = require '../models/languages'

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

# Currently active language.
current = new can.Map {}

# Watch changes to the key...
current.bind 'key', (ev, newVal, oldVal) ->
    # ... and save it to the user db.
    db.attr 'language', newVal

# Observe language selection.
languages.on 'change', (obj, property, evt, newVal) ->
    # Added on xhr, set by user.
    return unless evt in [ 'add', 'set' ]
    # Only care for setting, not resetting.
    return unless newVal
    if m = property.match /^(\d+)\.active$/
        # Use the label to show as `current`.
        current.attr languages.attr(parseInt m[1]).attr(), yes

# The select field UI element.
module.exports = can.Component.extend

    tag: 'app-select'

    template: require '../templates/select'

    scope: (obj, parent, el) ->
        {
            # All the languages.
            'languages': languages
            # The currently selected language.
            'current':   current
            # Dropdown filter.
            'query':
                'value': query
            # Are we showing dropdown?
            'expanded':
                'value': expanded
            # Dropdown click event.
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
            no # we are watching clicks on document too...

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