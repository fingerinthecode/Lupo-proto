angular.module('session')
.factory 'account', (session, crypto, fileManager, storage) ->
  {
    getMainDocId: (login, password) ->
      crypto.hash(login + password, 32)

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
        console.log "session registered"
        # public doc
        storage.save({
          name: username
          publicKey: keys.public
          _id: crypto.hash(keys.public)
        }).then (publicDoc) =>
          console.log "pubDoc", publicDoc
          fileManager.createRootFolder(masterKey).then (rootId) =>
            console.log "root", rootId, "created"
            privateUserDoc.data = {
              "privateKey": keys.private,
              "rootId": rootId,
              "publicDocId": publicDoc.id
            }
            crypto.encryptDataField(masterKey, privateUserDoc)
            storage.save(privateUserDoc).then =>
              session.registerSession(
                login, username, masterKey
                keys.private, keys.public, rootId)

    signIn: (login, password) ->
      _id = this.getMainDocId(login, password)
      console.log _id
      storage.get(_id).then(
        (privateDoc) =>
          masterKey = crypto.getMasterKey(password, privateDoc.salt)
          try
            crypto.decryptDataField(masterKey, privateDoc)
            console.log "private data", privateDoc.data
            storage.get(privateDoc.data.publicDocId).then(
              (publicDoc) =>
                session.registerSession(
                  login, publicDoc.name, masterKey
                  privateDoc.data.privateKey, privateDoc.data.publicKey,
                  privateDoc.data.rootId)
              (err) =>
                return 'no public doc'
            )
          catch SyntaxError
            return 'wrong password'
        (err) =>
          return 'no corresponding private doc'
      )

    signOut: ->
      session.deleteSession()
  }