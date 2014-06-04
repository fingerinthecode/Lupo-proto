angular.module('session')
.factory 'account', (session, User, crypto, fileManager, storage) ->
  {
    getMainDocId: (login, password) ->
      _funcName = "getMainDocId"
      console.log _funcName, login
      crypto.hash(login + password, 32)

    signUp: (login, password, publicName) ->
      console.log "signUp"
      username = if publicName? then publicName else login
      privateUserDoc = {}

      privateUserDoc.salt = crypto.newSalt(2)
      masterKey = crypto.getMasterKey(password, privateUserDoc.salt)
      assert(masterKey?, "error in masterKey generation (Session)")

      privateUserDoc._id = this.getMainDocId(login, password)
      assert(privateUserDoc._id?)

      crypto.createRSAKeys(2048).then (keys) =>
        # public doc
        storage.save({
          "name": username
          "publicKey": keys.public
          "_id": crypto.publicKeyIdFromKey(keys.public)
        }).then (publicDoc) =>
          fileManager.createRootFolder(masterKey).then (rootId) =>
            privateUserDoc.data = {
              "privateKey": keys.private,
              "rootId": rootId,
              "publicDocId": publicDoc.id
            }
            crypto.encryptDataField(masterKey, privateUserDoc)
            storage.save(privateUserDoc).then =>
              session.user = new User(
                login, username, masterKey
                keys.private, keys.public, rootId)

    signIn: (login, password) ->
      console.log "signIn", login
      _id = @getMainDocId(login, password)
      storage.get(_id).then(
        (privateDoc) =>
          console.log privateDoc
          masterKey = crypto.getMasterKey(password, privateDoc.salt)
          try
            crypto.decryptDataField(masterKey, privateDoc)
            storage.get(privateDoc.data.publicDocId).then(
              (publicDoc) =>
                console.log "publicDoc", publicDoc
                session.user = new User(
                  login, publicDoc.name, masterKey
                  privateDoc.data.privateKey, publicDoc.publicKey,
                  privateDoc.data.rootId)
            )
          catch SyntaxError
            return 'wrong password'
      )

    signOut: ->
      delete session.user
  }