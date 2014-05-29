angular.module('crypto').
factory('crypto', ($q)->
   object = {
      newSalt: (nbwords) =>
        sjcl.random.randomWords(nbwords)
      ,
      getMasterKey: (password, salt) ->
        assert(password?, "password must not be empty")
        assert(salt?, "salt must not be empty")
        return sjcl.misc.pbkdf2(password, salt, 1000, 256)
      ,
      createRSAKeys: (keySize) ->
        assert(keySize? and keySize > 0)
        deferred = $q.defer()
        crypt = new JSEncrypt({default_key_size: 2048})
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
    }
)

