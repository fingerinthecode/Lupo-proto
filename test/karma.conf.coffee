path = require('path')

module.exports = (config) ->
  config.set({
    basePath: './'
    frameworks: ['jasmine', 'commonjs', 'traceur']

    files: [
      './node_modules/es6-shim/es6-shim.js'
      './test/jasmine.matchers.coffee'
      './node_modules/di/src/*.js'
      './src/**/*.coffee'
      './test/unit/**/*.coffee'
    ]

    preprocessors: {
      './test/jasmine.matchers.coffee': ['coffee']
      './node_modules/di/src/*.js': ['traceur', 'commonjs']
      './src/**/*.coffee': ['coffee', 'regex', 'traceur', 'commonjs']
      './test/unit/**/*.coffee': ['coffee', 'regex', 'traceur', 'commonjs']
    }

    regexPreprocessor: {
      rules: [
        [ /(\@\w+\(.*\));/g, '$1' ]
        [ /from +\'(.*)\'/g, (match, file)->
          shims = require('./../package.json').shim ? {}
          for key, shim of shims
            if "from '#{shim.exports}'" is match
              # Get the absolute path
              shimpath = path.resolve('./', shim.path)
              # Remove the filename
              filepath = path.dirname(file.originalPath)
              # Get the relative path
              relative = path.relative(filepath, shimpath)
              # If on windows replace all backslashes by slashes
              relative = relative.replace(/\\/g, '\/')
              match    = "from './#{relative}'"
              break

          # If it's an directory add index.js
          if match.charAt(match.length-1) is '/'
            return "#{match}index.js"
          return match
        ]
      ]
    }

    traceurPreprocessor: {
      options:
        sourceMaps: true
        modules: 'commonjs'
        annotations: true

      transformPath: (path)->
        return path.replace(/\.coffee$/, '.js')
    }

    browsers: [
      'Firefox'
    ]
    reporters: ['dots']
  })
