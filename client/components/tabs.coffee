job = require '../models/job'

# First tab is active.
module.exports = active = can.compute 0

# We keep the tabs labels in a list so we get a nice scope for events.
tabs = new can.List [
    {
        'label': 'Editor'
        'icon':  'code'
        'show':  yes
    }, {
        'label': 'Results'  # text
        'fade':  yes        # shall we fade the background color
        'icon':  'terminal' # tab icon
        'show':  no         # show in the menu
    }, {
        'label': 'Discussion'
        'fade':  yes
        'icon':  'comment'
        'show':  yes
    }
]

# Show second tab when we have a job.
job.on 'change', ->
    tabs.attr(1).attr 'show', yes

# When a job is running, change the second tab icon to a spinner.
job.on 'status', (evt, status) ->
    tabs.attr(1).attr 'icon'
    , if status is 'running' then 'spin6' else 'terminal'

# Not exported! Not that it matters...
can.Component.extend

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