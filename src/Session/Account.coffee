angular.module('session')
.factory 'account', (session, User, crypto, fileManager, storage, $q) ->
  {
    getMainDocId: (login, password) ->
      _funcName = "getMainDocId"
      console.log _funcName, login
      crypto.hash(login + password, 32)

    signUp: (login, password, publicName)->
      defer = $q.defer()
      @signIn(login, password).then(
        => #Success
          defer.reject('User already exist')
        ,=> #Error
          @_signUp(login, password, publicName).then(
            -> #Success
              defer.resolve()
            (err)-> #Error
              defer.reject(err)
          )
      )
      return defer.promise

    _signUp: (login, password, publicName) ->
      console.log "signUp"
      username = if publicName? and publicName != "" then publicName else login
      privateUserDoc = {}

      privateUserDoc.salt = crypto.newSalt(16)
      masterKey = crypto.getMasterKey(password, privateUserDoc.salt)
      assert(masterKey?, "error in masterKey generation (Session)")
      masterKeyId = session.registerKey(masterKey)

      privateUserDoc._id = this.getMainDocId(login, password)
      assert(privateUserDoc._id?)

      crypto.createRSAKeys(2048).then (keys) =>
        publicDoc = {
          "name": username
          "publicKey": keys.public
          "_id": crypto.getKeyIdFromKey(keys.public)
        }
        storage.save(publicDoc).then =>
          fileManager.createRootFolder(masterKeyId).then (rootId) =>
            privateUserDoc.data = {
              "privateKey": keys.private,
              "rootId": rootId,
              "publicDocId": publicDoc._id
              "prefs": {
                "displayThumb": true
              }
            }
            clearData = angular.copy(privateUserDoc.data)
            crypto.encryptDataField(masterKey, privateUserDoc).then =>
              storage.save(privateUserDoc).then (savedPrivateDoc) =>
                session.user = new User(
                  username, publicDoc, login
                  masterKey, {
                    _id: savedPrivateDoc.id
                    _rev: savedPrivateDoc.rev
                    data: clearData
                  })
                console.error "SIGNUP FINISHED"

    signIn: (login, password) ->
      console.log "signIn", login
      _id = @getMainDocId(login, password)
      storage.get(_id).then(
        (privateDoc) =>
          console.log privateDoc
          masterKey = crypto.getMasterKey(password, privateDoc.salt)
          session.registerKey(masterKey)
          try
            crypto.decryptDataField(masterKey, privateDoc).then =>
              storage.get(privateDoc.data.publicDocId).then(
                (publicDoc) =>
                  console.log "publicDoc", publicDoc, masterKey
                  session.user = new User(
                    publicDoc.name, publicDoc
                    login, masterKey, privateDoc)
              )
          catch SyntaxError
            return 'wrong password'
      )

    signOut: ->
      delete session.user
  }
