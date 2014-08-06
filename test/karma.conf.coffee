module.exports = (config) ->
  config.set({
    frameworks: ['jasmine']

    files: [
      './static/js/main.js'
      './test/unit/**/*.coffee'
    ]

    preprocessors: {
      './test/unit/**/*.coffee': ['coffee']
    }

    browsers: [
      'PhantomJS'
    ]

    reporters: ['dots']
  })
