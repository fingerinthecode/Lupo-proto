angular.module('session')
.factory 'session', (crypto, LocalOrRemoteDoc) ->
  {
    getMainDocId: (login, password) ->
      sjcl.codec.hex.fromBits(sjcl.hash.sha256.hash(login + password))[0..32]

    getMainPublicKey: ->
      this.mainPublicKey

    getMainPrivateKey: ->
      this.mainPrivateKey

    getMasterKey: ->
      this.masterKey

    isConnected: ->
      this.login?
    registerSession: (login, username, masterKey, privateKey, publicKey) ->
      this.login = login
      this.username = username
      this.masterKey = masterKey
      this.mainPrivateKey = privateKey
      this.mainPublicKey = publicKey

    signUp: (login, password, publicName) ->
      username = if publicName? then publicName else login
      privateUserDoc = {}

      privateUserDoc.salt = crypto.newSalt(2)
      masterKey = crypto.getMasterKey(password, privateUserDoc.salt)
      assert(masterKey?, "error in masterKey generation (Session)")
      console.log "masterkey", masterKey

      privateUserDoc._id = this.getMainDocId(login, password)
      assert(privateUserDoc._id?)
      console.log "privDocId", privateUserDoc._id

      crypto.createRSAKeys(1024).then (keys) =>
        this.registerSession(login, username, masterKey, keys.private, keys.public)
        console.log "session registered"
        # public doc
        LocalOrRemoteDoc.put({
          name: username
          publicKey: this.getMainPublicKey()
        }).then(
          (publicDoc) =>
            console.log "pubDoc", publicDoc
            to_encrypt = JSON.stringify({
              "privateKey": this.getMainPrivateKey(),
              "root": [],
              "publicDocId": publicDoc.id
            })
            privateUserDoc.data = crypto.symEncrypt(masterKey, to_encrypt)
            assert(privateUserDoc.data?)
            return LocalOrRemoteDoc.put(privateUserDoc)
        )

    signIn: (login, password) ->
      _id = this.getMainDocId(login, password)
      LocalOrRemoteDoc.get(_id).then(
        (privateDoc) =>
          masterKey = crypto.getMasterKey(password, privateDoc.salt)
          try
            privateData = JSON.parse(crypto.symDecrypt(masterKey, privateDoc.data))
            console.log "private data", privateData
            LocalOrRemoteDoc.get(privateData.publicDocId).then(
              (publicDoc) =>
                this.registerSession(login, publicDoc.name, masterKey, privateData.privateKey, publicDoc.publicKey)
              (err) =>
                return 'no public doc'
            )
          catch SyntaxError
            return 'wrong password'
        (err) =>
          #deferred.reject('no corresponding private doc')
          return 'no corresponding private doc'
      )
      #return deferred
  }