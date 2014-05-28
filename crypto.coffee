angular.module('lupo-proto').
factory('crypto', (dependence)->
   object = {
      newSalt: (nbwords) =>
        sjcl.random.randomWords(nbwords)
      ,
      getMasterKey: (password, salt) =>
        sjcl.misc.pbkdf2(password, salt, 1000, 256)
      ,
      createRSAKeys: (keySize) =>
        deferred = $q.defer()
        crypt = new JSEncrypt({default_key_size: 2048})
        crypt.getKey(->
          deferred_rsa.resolve()
        )
        return deferred.promise
      ,
      symEncrypt = (key, data) =>
        # temporary: no IV
        aes = sjcl.cipher.aes(key)
        aes.encrypt(data)
      ,
      symDecrypt = (key, data) =>
        # temporary: no IV
        aes = sjcl.cipher.aes(key)
        aes.decrypt(data)
    }
)

