module.exports = (grunt) ->
    grunt.initConfig
        pkg: grunt.file.readJSON("package.json")
        
        apps_c:
            commonjs:
                src: [ 'client/app/**/*.{coffee,js,eco,mustache}' ]
                dest: 'public/js/runnable.js'
                options:
                    main: 'client/app/index.coffee'
                    name: 'runnable'

        stylus:
            compile:
                src: [ 'client/app/styles/**/*.styl' ]
                dest: 'public/css/runnable.css'

        concat:            
            scripts:
                src: [
                    # Vendor dependencies.
                    'vendor/jquery/jquery.js'
                    'vendor/lodash/dist/lodash.js'

                    'vendor/canjs/can.jquery.js'
                    'vendor/canjs/can.map.setter.js'
                    
                    'vendor/codemirror/lib/codemirror.js'
                    'vendor/codemirror/mode/javascript/javascript.js'
                    'vendor/codemirror/mode/coffeescript/coffeescript.js'
                    'vendor/codemirror/mode/ruby/ruby.js'
                    
                    # Our app.
                    'public/js/runnable.js'
                ]
                dest: 'public/js/runnable.bundle.js'
                options:
                    separator: ';' # for minification purposes

            styles:
                src: [
                    'vendor/foundation/css/normalize.css'
                    'client/app/styles/fonts.css'
                    'vendor/codemirror/lib/codemirror.css'
                    # Our app.
                    'public/css/runnable.css'
                ]
                dest: 'public/css/runnable.bundle.css'

        uglify:
            scripts:
                files:
                    'public/js/runnable.min.js': 'public/js/runnable.js'
                    'public/js/runnable.bundle.min.js': 'public/js/runnable.bundle.js'

        cssmin:
            combine:
                files:
                    'public/css/runnable.bundle.min.css': 'public/css/runnable.bundle.css'
                    'public/css/runnable.min.css': 'public/css/runnable.css'

    grunt.loadNpmTasks('grunt-apps-c')
    grunt.loadNpmTasks('grunt-contrib-stylus')
    grunt.loadNpmTasks('grunt-contrib-concat')
    grunt.loadNpmTasks('grunt-contrib-uglify')
    grunt.loadNpmTasks('grunt-contrib-cssmin')

    grunt.registerTask('default', [
        'apps_c'
        'stylus'
        'concat'
    ])

    grunt.registerTask('minify', [
        'uglify'
        'cssmin'
    ])