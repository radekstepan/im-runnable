# First tab is active.
active = can.compute 0

# We keep the tabs labels in a list so we get a nice scope for events.
tabs = new can.List [
    {
        'label': 'Editor'
        'classes': 'icon code'
    }, {
        'label': 'Results'
        'classes': 'icon terminal fade'        
    }, {
        'label': 'Discussion'
        'classes': 'icon comment fade'
    }
]

module.exports = can.Component.extend

    tag: 'app-tabs'

    template: require '../templates/tabs'

    scope: (obj, parent, el) ->
        {
            tabs,   # the tabs list
            switch: (item, el, evt) -> # can-click helper
                active _.findIndex tabs, do item.attr
        }

    helpers:
        # Is a tab active or not?
        isActive: (idx, opts) ->
            # Sometimes a function, sometimes a number.
            idx = do idx if _.isFunction idx

            # Does the numeric index match the current active tab?
            if idx is do active
                opts.fn @
            else
                opts.inverse @