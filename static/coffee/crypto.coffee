lupoCrypto =
  call: (method, args, callback) ->
    if callback?
      args.push(callback)
    @[method].apply(@, args)

  createRSAKeys: (keySize, callback) ->
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

  asymEncrypt: (publicKey, data, callback) ->
    crypt = new JSEncrypt()
    crypt.setPublicKey(publicKey)
    result = {
      data: crypt.encrypt JSON.stringify(data)
      algo: "rsa"
    }
    if callback?
      callback(result)
    return result

  asymDecrypt: (privateKey, dataObj, callback) ->
    crypt = new JSEncrypt()
    crypt.setPrivateKey(privateKey)
    result = JSON.parse (
      crypt.decrypt(dataObj.data)
    )
    if callback?
      callback(result)
    return result

  symEncrypt: (iv, key, data, callback) ->
    console.debug "symEncrypt", iv, key, data
    algo = 'AES-CBC'
    cipher = forge.cipher.createCipher(algo, key)
    cipher.start({iv: iv})
    cipher.update(forge.util.createBuffer(data))
    cipher.finish()
    result = {
      data: cipher.output.getBytes()
      algo: algo
      iv:   btoa iv
    }
    console.log "sizes", data.length, result.data.length, result.data.length/data.length
    if callback?
      callback(result)
    return result

  symDecrypt: (key, obj, callback) ->
    console.debug "symDecrypt", key, obj
    decipher = forge.cipher.createDecipher(obj.algo, key)
    decipher.start({iv: atob obj.iv})
    decipher.update(forge.util.createBuffer(obj.data))
    try
      decipher.finish()
      result = decipher.output.data
    catch err
      console.error "symDecrypt error", err
      result = undefined
    console.log "result", result
    if callback?
      callback(result)
    return result
