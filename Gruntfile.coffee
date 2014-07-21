module.exports = (grunt) ->
  require('load-grunt-tasks')(grunt)

  grunt.initConfig({
    watch: {
      options:
        livereload: true
      sass: {
        files: [
          './static/sass/{,*/}*.sass'
          './partials/{,*/}*.html'
        ]
        tasks: [
          'compass'
        ]
      }
      all: {
        files: [
          './src/{,*/}*'
        ]
        tasks: [
          'coffee'
        ]
      }
    }
    compass: {
      dist: {
        options:
          sassDir:   './static/sass/'
          cssDir:    './static/css/'
          imagesDir: './static/img/'
          javascriptsDir: './static/js/'
          fontsDir: 'static/fonts/'
          outputStyle: 'expanded'
          relativeAssets: true
          watch: false
      }
    }
    concat: {
      dist: {
        src: [
          'temp/*/__init__.js'
          'temp/*/config.js'
          'temp/*/routes.js'
          'temp/*/run.js'
          'temp/*/*.js'
        ]
        dest: 'static/js/main.js'
        options:
          process: (content, src) ->
            src = src.split('/')
            src = src[src.length-1] # Get file name
            if src[0].toUpperCase() == src[0] ||
            src == 'config.js' ||
            src == 'routes.js' ||
            src == 'run.js'
              return content
            else
              return ''
      }
    }
    coffee: {
      options:
        bare: true
      dist: {
        expand: true
        cwd: 'src/'
        src: '*/*.coffee'
        dest: 'temp/'
        ext: '.js'
      }
      lib: {
        expand: true
        cwd: 'static/coffee'
        src: '*.coffee'
        dest: 'static/js/'
        ext: '.js'
      }
    }
    copy: {
      dist: {
        expand: true
        filter: 'isFile'
        cwd: 'src/'
        src: '*/*.js'
        dest: 'temp/'
      }
    }
    clean: {
      options:
        force: true
      dist: {
        src: [
          "temp/"
        ]
      }
    }
    concurrent: {
      options:
        logConcurrentOutput: true
      dev: ['shell:server', 'watch']
    }
    # Kanso
    shell:{
      options:
        stdout: true
      kansoDelete:{
        options:
          failOnError: false
        command: ->
          name = grunt.option('db') || 'default'
          return "kanso deletedb #{name}"
      }
      kansoCreate:{
        command: ->
          name = grunt.option('db') || 'default'
          return "kanso createdb #{name}"
      }
      kansoInit:{
        command: ->
          name = grunt.option('db') || 'default'
          return "kanso upload ./data #{name}"
      }
      kansoPush:{
        command: ->
          name = grunt.option('db') || 'default'
          return "kanso push #{name}"
      }
      protractor_update: {
        command: 'node ./node_modules/protractor/bin/webdriver-manager update'
      }
      server: {
        command: 'node ./node_modules/coffee-script/bin/coffee ./server.coffee'
      }
    }
    #Unit
    karma: {
      unit: {
        configFile: './test/karma.conf.coffee',
        autoWatch: true
      }
    }
    #E2E
    protractor: {
      dev: {
        options:
          configFile: "test/e2e.conf.coffee"
      }
    },
    selenium_webdriver_phantom: {
      phantom: {
        options: {
          chrome: {
          }
        }
      }
    }
  })

  grunt.registerTask('default', [
    'concurrent'
  ])

  grunt.registerTask('test_database', 'set the db option to the database test', ->
    grunt.option('db', 'testing')
  )

  grunt.registerTask('test', [
    'karma:unit'
  ])

  grunt.registerTask('e2e', [
    'test_database'
    'init'
    'shell:protractor_update'
    'selenium_webdriver_phantom:phantom'
    'protractor'
    'selenium_webdriver_phantom:stop'
    'shell:kansoDelete'
  ])

  grunt.registerTask('compile', [
    'compass'
    'copy'
    'coffee'
    'concat'
    'clean'
  ])

  grunt.registerTask('init', [
    'shell:kansoDelete'
    'shell:kansoCreate'
    'shell:kansoInit'
    'shell:kansoPush'
  ])
