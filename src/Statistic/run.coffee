angular.module('statistic').
run (storage)->
  id = new Fingerprint().get()
  storage.save({
    _id:  "stats:#{id}"
    id:   id
    type: "stats"
    created_at: new Date().getTime()
    browser: {
      name: Device.browser()
      vers: Device.vers()
    }
    device: Device.device()
    os:     Device.os()
    lang:   window.navigator.language
    ua:     window.navigator.userAgent
  })
