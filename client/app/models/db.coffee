ls = window.localStorage

DB = can.Model.extend
    
    # localStorage key prefix.
    dbName: md5 "im-runnable-#{document.location.hostname}"

    # Init localStorage keys for quick access to items.
    keys: null

    init: ->
        item = ls.getItem @dbName
        # Load user data?
        if (@keys = (item and item.split(',')) or []).length
            for key in @keys
                @attr key, JSON.parse ls.getItem "#{@dbName}-#{key}"

# Init with the defaults.
module.exports = db = new DB
    'language': 'javascript' # TODO this language needs to exist when xhr

# Propagate changes to localStorage.
db.bind 'change', (ev, attr, how, newVal, oldVal) ->
    switch how
        when 'set'
            ls.setItem "#{@dbName}-#{attr}", JSON.stringify newVal
            # Save the key too.
            @keys.push attr unless attr in @keys
            # Save all the keys.
            ls.setItem @dbName, @keys.join(',')