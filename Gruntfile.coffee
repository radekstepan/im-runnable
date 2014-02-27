module.exports = (grunt) ->
    grunt.initConfig
        pkg: grunt.file.readJSON("package.json")
        
        apps_c:
            commonjs:
                src: [ 'client/**/*.{coffee,js,eco,mustache,json}' ]
                dest: 'public/js/runnable.js'
                options:
                    main: 'client/index.coffee'
                    name: 'runnable'

        stylus:
            compile:
                src: [ 'client/styles/**/*.styl' ]
                dest: 'public/css/runnable.css'

        shell:
            highlight:
                options:
                    stdout: yes
                # The JSON output is actually highlighted as JavaScript to match the code editor.
                command: 'cd ./vendor/highlight.js/ ; python ./tools/build.py -tbrowser json javascript'

        concat:            
            scripts:
                src: [
                    # Vendor dependencies.
                    'vendor/jquery/jquery.js'
                    'vendor/lodash/dist/lodash.js'
                    'vendor/js-md5/js/md5.js'

                    # canJS.
                    'vendor/canjs/can.jquery.js'
                    'vendor/canjs/can.map.setter.js'
                    
                    # CodeMirror.
                    'vendor/codemirror/lib/codemirror.js'
                    'vendor/codemirror/mode/clike/clike.js'
                    'vendor/codemirror/mode/javascript/javascript.js'
                    'vendor/codemirror/mode/coffeescript/coffeescript.js'
                    'vendor/codemirror/mode/perl/perl.js'
                    'vendor/codemirror/mode/python/python.js'
                    'vendor/codemirror/mode/ruby/ruby.js'

                    # Highlight.js is built using `shell` task.
                    'vendor/highlight.js/build/highlight.pack.js'
                    
                    # Our app.
                    'public/js/runnable.js'
                ]
                dest: 'public/js/runnable.bundle.js'
                options:
                    separator: ';' # for minification purposes

            styles:
                src: [
                    'vendor/foundation/css/normalize.css'
                    'vendor/foundation/css/foundation.css'
                    'client/styles/fonts.css'
                    
                    # Editors.
                    'vendor/codemirror/lib/codemirror.css'
                    'vendor/highlight.js/src/styles/github.css'
                    
                    # Our app.
                    'public/css/runnable.css'
                ]
                dest: 'public/css/runnable.bundle.css'

        # uglify:
        #     scripts:
        #         files:
        #             'public/js/runnable.min.js': 'public/js/runnable.js'
        #             'public/js/runnable.bundle.min.js': 'public/js/runnable.bundle.js'

        # cssmin:
        #     combine:
        #         files:
        #             'public/css/runnable.bundle.min.css': 'public/css/runnable.bundle.css'
        #             'public/css/runnable.min.css': 'public/css/runnable.css'

    grunt.loadNpmTasks('grunt-apps-c')
    grunt.loadNpmTasks('grunt-shell')
    grunt.loadNpmTasks('grunt-contrib-stylus')
    grunt.loadNpmTasks('grunt-contrib-concat')
    # grunt.loadNpmTasks('grunt-contrib-uglify')
    # grunt.loadNpmTasks('grunt-contrib-cssmin')

    grunt.registerTask('default', [
        'apps_c'
        'stylus'
        'concat'
    ])

    # grunt.registerTask('minify', [
    #     'uglify'
    #     'cssmin'
    # ])

    grunt.registerTask('full', [
        'shell'
        'apps_c'
        'stylus'
        'concat'
        # 'uglify'
        # 'cssmin'
    ])