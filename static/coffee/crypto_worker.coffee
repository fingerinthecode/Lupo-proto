@window = @
importScripts('../vendor/jsencrypt/bin/jsencrypt.js')
importScripts('../vendor/forge/js/forge.bundle.js')
importScripts('crypto.js')

@addEventListener 'message',
  (e) ->
    result = lupoCrypto.call(e.data.method, e.data.args)
    self.postMessage {
        id: e.data.id
        result: result
      }
  false