angular.module('crypto').
factory('crypto', ($q, assert)->
  defers = {}
  id = 0
  if window.Worker?
    worker = new Worker("js/crypto_worker.js")
    worker.addEventListener 'message', (e) ->
      if e.data.result?
        defers[e.data.id].resolve(e.data.result)
      else
        defers[e.data.id].reject()

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
      lupoCrypto.call method, args, (result) ->
        if result?
          defers[id].resolve(result)
        else
          defers[id].reject()
    return defers[id].promise

  return {
    keyLength: 16

    isEncrypted: (doc) ->
      return angular.isObject(doc.data) and doc.data.algo? and doc.data.data?

    newSalt: (size) ->
      _funcName = "newSalt"
      console.log _funcName
      assert.defined size, "size", _funcName
      forge.random.getBytesSync(size)

    hash: (data, size) ->
      _funcName = "hash"
      console.log _funcName
      assert.defined data, "data", _funcName
      md = forge.md.sha256.create()
      md.update(data)
      h = md.digest().toHex()
      return if size then h[0..size-1] else h

    getMasterKey: (password, salt) ->
      _funcName = "getMasterKey"
      console.log _funcName
      assert.defined password, "password", _funcName
      assert.defined salt, "salt", _funcName
      forge.pkcs5.pbkdf2(password, salt, 1000, @keyLength)

    generateSymKey: (size) ->
      _funcName = "generateSymKey"
      if not size?
        size = @keyLength * 16
      console.log _funcName, size
      random1 = @newSalt(size / 16)
      random2 = @newSalt(size / 16)
      forge.pkcs5.pbkdf2(random1, random2, 1000, size / 16)

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
      iv = @newSalt(16)
      return asyncCall _funcName, iv, key, data


    symDecrypt: (key, obj) ->
      _funcName = "symDecrypt"
      assert.defined key, "key", _funcName
      assert.defined obj, "obj", _funcName
      return asyncCall _funcName, key, obj
  }
)

