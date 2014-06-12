crypto =
  call: (method, args, callback) ->
    console.info method, args, callback
    if callback?
      args.push(callback)
    @[method].apply(@, args)

  newSalt: (nbWords, callback) ->
    result = sjcl.random.randomWords(nbwords)
    if callback?
      callback(result)
    return result

  hash: (data, size) ->
    h = sjcl.codec.hex.fromBits(sjcl.hash.sha256.hash(data))
    result = if size then h[0..size] else h
    if callback?
      callback(result)
    return result

  getMasterKey: (password, salt) ->
    result = sjcl.codec.hex.fromBits(
      sjcl.misc.pbkdf2(password, salt, 1000, 256)
    )
    if callback?
      callback(result)
    return result

  createRSAKeys: (keySize, callback) ->
    _funcName = "createRSAKeys"
    console.log _funcName, keySize, callback
    crypt = new JSEncrypt({default_key_size: keySize})
    if callback?
      crypt.getKey ->
        callback {
          public: crypt.getPublicKey()
          private: crypt.getPrivateKey()
        }
    else
      crypt.getKey()
      return {
        public: crypt.getPublicKey()
        private: crypt.getPrivateKey()
      }

  asymEncrypt: (publicKey, data) ->
    crypt = new JSEncrypt()
    crypt.setPublicKey(publicKey)
    result = crypt.encrypt(
      JSON.stringify(data)
    )
    if callback?
      callback(result)
    return result

  asymDecrypt: (privateKey, data) ->
    crypt = new JSEncrypt()
    crypt.setPrivateKey(privateKey)
    result = JSON.parse (
      crypt.decrypt(data)
    )
    if callback?
      callback(result)
    return result

  symEncrypt: (iv, key, data, callback) ->
    key = sjcl.codec.hex.toBits key
    aes = new sjcl.cipher.aes(key)
    result = {
      data: 	sjcl.mode.ccm.encrypt(aes, sjcl.codec.utf8String.toBits(data), iv)
      algo: "aes",
      iv: @newSalt(4)
    }
    if callback?
      callback(result)
    return result

  symDecrypt: (key, obj, callback) ->
    key = sjcl.codec.hex.toBits key
    aes = new sjcl.cipher.aes(key)
    result = sjcl.codec.utf8String.fromBits(
      sjcl.mode.ccm.decrypt(aes,  obj.data, obj.iv)
    )
    if callback?
      callback(result)
    return result
