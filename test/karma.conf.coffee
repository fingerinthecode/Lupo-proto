module.exports = (config) ->
  config.set({
    frameworks: ['jasmine', 'requirejs', 'traceur']

    files: [
      {pattern: './node_modules/es6-shim/es6-shim.js', included: false}
      {pattern: './tmp/src/**/*.js', included: false}
      {pattern: './tmp/unit/**/*.js', included: false}
      './test/test-main.js'
      './test/jasmine.matchers.coffee'
    ]

    preprocessors: {
      './node_modules/es6-shim/es6-shim.js': ['traceur']
      './tmp/src/**/*.js': ['traceur']
      './tmp/unit/**/*.js': ['traceur']
      './test/jasmine.matchers.coffee': ['coffee']
    }

    browsers: [
      'Firefox'
    ]

    reporters: ['dots']

    traceurPreprocessor: {
      options:
        sourceMap: true
        modules: 'amd'
    }
  })
