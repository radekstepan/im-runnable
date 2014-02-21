module.exports = can.Component.extend

    tag: 'app-select'

    template: require '../templates/select'

    events:
        # Toggle the field dropdown.
        '.field click': (el, evt) ->
            @element.find('.select').toggleClass('expanded')
            (icon = el.find('.icon')).toggleClass('down-dir up-dir')
            do @element.find('.dropdown').toggle