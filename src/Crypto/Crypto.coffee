angular.module('crypto').
factory('crypto', ($q, assert)->
  defers = {}
  id = 0
  if window.Worker?
    worker = new Worker("js/crypto_worker.js")
    worker.addEventListener 'message', (e) ->
      console.log "RECEIVED", e.data
      defers[e.data.id].resolve(e.data.result)

  asyncCall = (method) ->
    id++
    defers[id] = $q.defer()
    args = (arg for arg in arguments)
    args = args[1..]
    if worker?
      worker.postMessage {
        id: id
        method: method
        args: args
      }
    else
      crypto.call method, args, (result) ->
        defers[id].resolve(result)
    return defers[id].promise

  syncCall = (method) ->
    id++
    defers[id] = $q.defer()
    args = (arg for arg in arguments)
    args = args[1..]
    if worker?
      worker.postMessage {
        id: id
        method: method
        args: args
      }
      locked = true
      result
      defers[id].promise.then (result) =>
        locked = false
        result = result
      while locked
        continue
      return result
    else
      return crypto.call method, args

  object = {
    newSalt: (nbwords) ->
      _funcName = "newSalt"
      console.log _funcName
      assert.defined nbwords, "nbwords", _funcName
      return syncCall _funcName, nbwords
    ,
    hash: (data, size) ->
      _funcName = "hash"
      console.log _funcName
      assert.defined data, "data", _funcName
      return syncCall _funcName, data, size

    getMasterKey: (password, salt) ->
      _funcName = "getMasterKey"
      console.log _funcName
      assert.defined password, "password", _funcName
      assert.defined salt, "salt", _funcName
      return syncCall _funcName, password, salt

    createRSAKeys: (keySize) ->
      _funcName = "createRSAKeys"
      console.log _funcName, keySize
      assert.defined keySize, "keySize", _funcName
      assert.custom(keySize > 0)
      return asyncCall _funcName, keySize

    getKeyIdFromKey: (key) ->
      _funcName = "getKeyIdFromKey"
      console.log _funcName
      assert.defined key, "key", _funcName
      @hash key, 32

    asymEncrypt: (publicKey, data) ->
      _funcName = "asymEncrypt"
      console.log _funcName, data
      assert.defined publicKey, "publicKey", _funcName
      assert.defined data, "data", _funcName
      return asyncCall _funcName, publicKey, data

    asymDecrypt: (privateKey, data) ->
      _funcName = "asymDecrypt"
      console.log _funcName, data
      assert.defined privateKey, "privateKey", _funcName
      assert.defined data, "data", _funcName
      return asyncCall _funcName, privateKey, data

    symEncrypt: (key, data) ->
      _funcName = "symEncrypt"
      assert.defined key, "key", _funcName
      assert.defined data, "data", _funcName
      return asyncCall _funcName, key, data


    symDecrypt: (key, obj) ->
      _funcName = "symDecrypt"
      assert.defined key, "key", _funcName
      assert.defined obj, "obj", _funcName
      return asyncCall _funcName, key, obj

    encryptDataField: (key, doc) ->
      _funcName = "encryptDataField"
      assert.defined key, "key", _funcName
      assert.defined doc, "doc", _funcName
      assert.defined doc.data, "doc.data", _funcName
      @symEncrypt(key, JSON.stringify(doc.data)).then (data) =>
        doc.data = data
    ,
    decryptDataField: (key, doc) ->
      _funcName = "decryptDataField"
      assert.defined key, "key", _funcName
      assert.defined doc, "doc", _funcName
      assert.defined doc.data, "doc.data", _funcName
      @symDecrypt(key, doc.data).then (data) =>
        doc.data = JSON.parse(data)
  }
)

