fs  = require('fs')
url = null
if fs.existsSync('.kansorc')
  conf = require('../.kansorc')
  url = conf.env?.testing?.db ? null

if not url?
  console.error('Unable to find testing in .kansorc')
  process.exit(1)

exports.config = {
  seleniumAddress: 'http://localhost:4444/wd/hub'
  baseUrl: "#{url}/_design/proto/_rewrite/"

  capabilities: {
    'browserName': 'firefox'
  }

  specs: [
    '../test/e2e/*Spec.coffee'
  ]

  onPrepare: ->
    global.select = global.by
    browser.addMockModule('testing', ->
      angular.module('testing', [])
        .value('dbname', 'testing')
        .run( ($animate)->
          $animate.enabled(false)
        )
    )


  jasmineNodeOpts: {
    showColors: true
    defaultTimeoutInterval: 30000
  }
}
