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
          './partials/{,*/}*.html'
          './src/{,*/}*'
        ]
        tasks: [
          'shell:kansoPush'
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
    # Kanso
    shell:{
      options:
        stdout: true
      kansoDelete:{
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
    }
  })


  grunt.registerTask('default', [
    'watch'
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
