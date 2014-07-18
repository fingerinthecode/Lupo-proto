angular.module('session')
.factory 'account', (session, User, crypto, fileManager, DbDoc, $q) ->
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
      console.debug "masterKey", masterKey
      assert(masterKey?, "error in masterKey generation (Session)")
      masterKeyId = session.registerKey(masterKey)
      session.saveFlash 'masterKey', masterKey

      privateUserDoc._id = this.getMainDocId(login, password)
      assert(privateUserDoc._id?)

      crypto.createRSAKeys(2048).then (keys) =>
        publicDoc = {
          "name": username
          "publicKey": keys.public
          "_id": crypto.getKeyIdFromKey(keys.public)
        }
        DbDoc.save(publicDoc).then =>
          fileManager.createRootFolder(masterKey).then (rootId) =>
            privateUserDoc.data = {
              "privateKey":  keys.private,
              "rootId":      rootId,
              "publicDocId": publicDoc._id
              "prefs": {
                "displayThumb": true
              }
            }
            clearData = {}
            for i,x of privateUserDoc.data
              clearData[i] = x
            #privateUserDoc.data = angular.copy(clearData)
            DbDoc.encryptAndSave(privateUserDoc, masterKey).then (savedPrivateDoc) =>
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
      DbDoc.get(_id).then(
        (privateDoc) =>
          console.log privateDoc
          masterKey = crypto.getMasterKey(password, privateDoc.salt)
          session.registerKey(masterKey)
          try
            DbDoc.decryptDataField(privateDoc, masterKey).then =>
              DbDoc.get(privateDoc.data.publicDocId).then(
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
