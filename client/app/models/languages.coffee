config = require './config'

Language = can.Model.extend
    'findAll': ->
        $.ajax
            'url':      '/api/languages'
            'type':     'get'
            'dataType': 'json'
, {}

# Xhr fetch and replace our list.
module.exports = languages = new Language.List do Language.findAll

# Some client side updates to server data when they are added.
languages.on 'add', (obj, list) ->
    for item in list
        # Activate the default language.
        item.attr 'active', yes if config.default_language is item.attr 'key'
        # Show us all.
        item.attr 'show', yes