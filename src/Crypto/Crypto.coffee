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

  return {
    newSalt: (nbwords) ->
      _funcName = "newSalt"
      console.log _funcName
      assert.defined nbwords, "nbwords", _funcName
      sjcl.random.randomWords(nbwords)

    ,
    hash: (data, size) ->
      _funcName = "hash"
      console.log _funcName
      assert.defined data, "data", _funcName
      h = sjcl.codec.hex.fromBits(sjcl.hash.sha256.hash(data))
      return if size then h[0..size] else h

    getMasterKey: (password, salt) ->
      _funcName = "getMasterKey"
      console.log _funcName
      assert.defined password, "password", _funcName
      assert.defined salt, "salt", _funcName
      sjcl.codec.hex.fromBits(
        sjcl.misc.pbkdf2(password, salt, 1000, 256)
      )

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
      iv = @newSalt(4)
      return asyncCall _funcName, iv, key, data


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

