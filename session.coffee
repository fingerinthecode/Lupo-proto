angular.module('lupo-proto').
factory('session', ($q, crypto)->
  object = {
    getDocId: (login, password) =>
      sjcl.hash.sha256.hash(login + password)[0..15]
    ,
    createDocId: (login, password) =>
      getDocId(login, password)
    ,
    getPrivateUserDoc: (_id) =>
      return {
        salt: ''
      }
    ,
    getPublicUserDoc: (_id) =>
      return {
        publicKey: '',
        name: ''
      }
    ,
    getPublicKey: () =>
      if this.crypto
        this.crypto.getPublicKey()
    ,
    getPrivateKey: () =>
      if this.crypto
        this.crypto.getPrivateKey()
    ,
    getMasterKey: () =>
      this.masterKey
    ,
    registerSession: (masterKey, privateKey, publicKey) =>
      this.masterKey = masterKey
      this.privateKey = privateKey
      this.publicKey = publicKey
    ,
    signup: (login, password, publicName) =>
      masterKey = crypto.getMasterKey(password, salt)

      keysReady = crypto.createRSAKeys(2048)
      privateUserDoc = {}
      publicUserDoc = {
        name: if publicName? then publicName else login
      }
      privateUserDoc._id = this.createDocId(login, password)
      privateUserDoc.salt = crypto.newSalt(2)


      keysReady.then =>
        this.registerSession(crypto, masterKey)

        publicUserDoc.publicKey = this.getPublicKey()
        registerPublicDoc(publicDoc).then (publicDocId) =>
          to_encrypt = JSON.stringify({
            "privateKey": this.getPrivateKey,
            "root": [],
            "publicDocId": publicDocId
          })
          privateUserDoc.data = crypto.symEncrypt(masterKey, to_encrypt)

        // send the 2 docs to db

        this.resolve()

      return keysReady
    ,
    login: (login, password) =>
      deferred = $.defer()
      _id = getDocId(login, password)
      getPrivateUserDoc(_id).then (privateDoc) =>
        masterKey = crypto.getMasterKey(password, privateDoc.salt)
        attempt = crypto.symDecrypt(masterKey, privateDoc.data)
        try
          JSON.parse(attempt)
          getPublicUserDoc(attempt.publicDocId).then (publicDoc) =>
            registerSession(masterKey, attempt.privateKey, publicDoc.publicKey)
            deferred.resolve()
        catch SyntaxError
          deferred.reject()
  }
