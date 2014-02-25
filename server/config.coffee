module.exports =
    # The languages/environments we support.
    'languages': [
        {
            # Identifier.
            'key': 'java'
            # Label in the UI
            'label': 'Java'
            # The command to run in Docker.
            'cmd': 'cat > script.java; javac script.java; java script'
            # The circle color in the UI.
            'color': '#F80000'
        }, {
            'key': 'javascript'
            'label': 'JavaScript (Node.js)'
            'cmd': 'cat > script.js; node script.js'
            'color': '#A8CD39'
        }, {
            'key': 'perl'
            'label': 'Perl'
            'cmd': 'cat > script.pl; perl script.pl'
            'color': '#7083BA'
        }, {
            'key': 'python'
            'label': 'Python'
            'cmd': 'cat > script.py; python script.py'
            'color': '#3F84B2'
        }, {
            'key': 'ruby'
            'label': 'Ruby'
            'cmd': 'cat > script.rb; ruby script.rb'
            'color': '#C32433'
        }
    ]

    # Queue settings.
    'queue':
        # How many commands can we run at a time (globally)?
        'concurrency': 1 # my system crashes if too high...
        # When do we cleanup jobs.
        'timeout': 5e4