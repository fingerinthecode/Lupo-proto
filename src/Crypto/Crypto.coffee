angular.module('crypto').
factory('crypto', ($q, assert)->
  _indent = "  "
  object = {
    newSalt: (nbwords) ->
      _funcName = _indent + "newSalt"
      console.log _funcName
      assert.defined nbwords, "nbwords", _funcName
      sjcl.random.randomWords(nbwords)
    ,
    hash: (data, size) ->
      _funcName = _indent + "hash"
      console.log _funcName
      assert.defined data, "data", _funcName
      h = sjcl.codec.hex.fromBits(sjcl.hash.sha256.hash(data))
      return if size then h[0..size] else h

    getMasterKey: (password, salt) ->
      _funcName = _indent + "getMasterKey"
      console.log _funcName
      assert.defined password, "password", _funcName
      assert.defined salt, "salt", _funcName
      sjcl.codec.hex.fromBits(
        sjcl.misc.pbkdf2(password, salt, 1000, 256)
      )

    createRSAKeys: (keySize) ->
      _funcName = _indent + "createRSAKeys"
      console.log _funcName, keySize
      assert.defined keySize, "keySize", _funcName
      assert.custom(keySize > 0)
      deferred = $q.defer()
      crypt = new JSEncrypt({default_key_size: keySize})
      crypt.getKey(->
        deferred.resolve {
          public: crypt.getPublicKey()
          private: crypt.getPrivateKey()
        }
      )
      return deferred.promise

    publicKeyIdFromKey: (publicKey) ->
      _funcName = _indent + "publicKeyIdFromKey"
      console.log _funcName
      assert.defined publicKey, "publicKey", _funcName
      @hash(publicKey, 32)

    asymEncrypt: (publicKey, data) ->
      _funcName = _indent + "asymEncrypt"
      console.log _funcName, publicKey, data
      assert.defined publicKey, "publicKey", _funcName
      assert.defined data, "data", _funcName
      crypt = new JSEncrypt()
      crypt.setPublicKey(publicKey)
      crypt.encrypt(
        JSON.stringify(data)
      )

    asymDecrypt: (privateKey, data) ->
      _funcName = _indent + "asymDecrypt"
      console.log _funcName, privateKey, data
      assert.defined privateKey, "privateKey", _funcName
      assert.defined data, "data", _funcName
      crypt = new JSEncrypt()
      crypt.setPrivateKey(privateKey)
      JSON.parse (
        crypt.decrypt(data)
      )

    symEncrypt: (key, data) ->
      _funcName = _indent + "symEncrypt"
      console.log _funcName
      assert.defined key, "key", _funcName
      assert.defined data, "data", _funcName
      iv = this.newSalt(4)
      key = sjcl.codec.hex.toBits key
      aes = new sjcl.cipher.aes(key)
      {
        data: 	sjcl.mode.ccm.encrypt(aes, sjcl.codec.utf8String.toBits(data), iv)
        algo: "aes",
        iv: iv
      }
    ,
    symDecrypt: (key, obj) ->
      _funcName = _indent + "symDecrypt"
      console.log _funcName
      assert.defined key, "key", _funcName
      assert.defined obj, "obj", _funcName
      key = sjcl.codec.hex.toBits key
      aes = new sjcl.cipher.aes(key)
      sjcl.codec.utf8String.fromBits(
        sjcl.mode.ccm.decrypt(aes,  obj.data, obj.iv)
      )
    ,
    encryptDataField: (key, doc) ->
      _funcName = _indent + "encryptDataField"
      console.log _funcName
      assert.defined key, "key", _funcName
      assert.defined doc, "doc", _funcName
      assert.defined doc.data, "doc.data", _funcName
      doc.data = @symEncrypt(key, JSON.stringify(doc.data))
    ,
    decryptDataField: (key, doc) ->
      _funcName = _indent + "decryptDataField"
      console.log _funcName
      assert.defined key, "key", _funcName
      assert.defined doc, "doc", _funcName
      assert.defined doc.data, "doc.data", _funcName
      doc.data = JSON.parse(@symDecrypt(key, doc.data))
  }
)

