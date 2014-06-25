exports.config = {
  seleniumAddress: 'http://localhost:4444/wd/hub',
  baseUrl: 'http://localhost:5984/lupo-proto/_design/proto/_rewrite/',

  capabilities: {
    'browserName': 'phantomjs'
  },

  specs: [
    '../test/e2e/test.js'
  ],

  jasmineNodeOpts: {
    showColors: true,
    defaultTimeoutInterval: 30000
  }
};
