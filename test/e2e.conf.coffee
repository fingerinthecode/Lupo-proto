exports.config = {
  seleniumAddress: 'http://localhost:4444/wd/hub'
  baseUrl: 'http://localhost:5984/lupo-proto/_design/proto/_rewrite/'

  capabilities: {
    'browserName': 'firefox'
  }

  specs: [
    '../test/e2e/*Spec.coffee'
  ]

  onPrepare: ->
    global.select = global.by

  jasmineNodeOpts: {
    showColors: true
    defaultTimeoutInterval: 30000
  }
}
