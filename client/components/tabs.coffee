# The actual tab switcher.
module.exports = can.Component.extend

    tag: 'app-tabs'

    template: require '../templates/tabs'

    scope: (obj, parent, el) -> {}

    events:
        # Toggle tabs.
        '.tabs li a:not(.active) click': (el, evt) ->
            # Someone else off - tab.
            @element.find('.tabs li a.active').removeClass 'active'
            # Me on - tab.
            el.addClass 'active'

            # Someone else off - content.
            @element.find('.tab-content.active').removeClass 'active'

            # Me on - content.
            key = el.data 'tab'
            @element.find(".tab-content[data-tab='#{key}']").addClass 'active'

        inserted: (el) ->
