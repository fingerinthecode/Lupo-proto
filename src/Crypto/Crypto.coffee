angular.module('crypto').
factory('crypto', ($q)->
   object = {
      newSalt: (nbwords) ->
        sjcl.random.randomWords(nbwords)
      ,
      hash: (data, size) ->
        h = sjcl.codec.hex.fromBits(sjcl.hash.sha256.hash(data))
        console.log h.length, h
        return if size then h[0..size] else h

      getMasterKey: (password, salt) ->
        assert(password?, "password must not be empty")
        assert(salt?, "salt must not be empty")
        return sjcl.misc.pbkdf2(password, salt, 1000, 256)
      ,
      createRSAKeys: (keySize) ->
        assert(keySize? and keySize > 0)
        deferred = $q.defer()
        crypt = new JSEncrypt({default_key_size: keySize})
        crypt.getKey(->
          deferred.resolve {
            public: crypt.getPublicKey()
            private: crypt.getPrivateKey()
          }
        )
        return deferred.promise
      ,
      symEncrypt: (key, data) ->
        assert(key?, "undefined key param of symEncrypt")
        assert(data?, "undefined data param of symEncrypt")
        console.log "symEncrypt, key:", key
        iv = this.newSalt(4)
        aes = new sjcl.cipher.aes(key)
        console.log aes, data
        {
          data: 	sjcl.mode.ccm.encrypt(aes, sjcl.codec.utf8String.toBits(data), iv)
          algo: "aes",
          iv: iv
        }
      ,
      symDecrypt: (key, obj) ->
        aes = new sjcl.cipher.aes(key)
        sjcl.codec.utf8String.fromBits(
          sjcl.mode.ccm.decrypt(aes,  obj.data, obj.iv)
        )
      ,
      encryptDataField: (key, doc) ->
        assert(doc.data?, "doc.data is undefined")
        doc.data = this.symEncrypt(key, JSON.stringify(doc.data))
        assert(doc.data != "", "encrypted data is empty")
      ,
      decryptDataField: (key, doc) ->
        assert(doc.data?, "doc.data is undefined")
        doc.data = JSON.parse(this.symDecrypt(key, doc.data))
        assert(doc.data != "", "decrypted data is empty")
    }
)

