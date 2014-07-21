module.exports = (config) ->
  config.set({
    basePath: '../'
    frameworks: ['jasmine']

    files: [
      'static/vendor/angular/*.js'
      'static/vendor/**/*.js'
      'static/js/main.js'
      'test/unit/*.coffee'
    ]
    exclude: [
      '**/*.min.js'
      'static/vendor/forge/js/*.js'
      'static/vendor/**/src/**/*.js'
      'static/vendor/**/index.js'
      'static/vendor/**/nodejs/**/*.js'
      'static/vendor/**/test/**/*.js'
      'static/vendor/**/tests/**/*.js'
      'static/vendor/jsencrypt/!(bin)/**/*.js'
    ]

    browsers: [
      'PhantomJS'
    ]

    reporters: ['dots']
  })
