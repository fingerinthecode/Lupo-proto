angular.module('session')
.factory 'session', (crypto, storage) ->
  {
    user: {}
    flash: {}
    keyRing: {}

    registerKey: (key) ->
      keyId = crypto.getKeyIdFromKey(key)
      @keyRing[keyId] = key
      return keyId

    getKey: (keyId) ->
      @keyRing[keyId]

    getMainPublicKey: ->
      @user.publicDoc.publicKey

    getUserId: ->
      @user.publicDoc._id

    getMainPrivateKey: ->
      @user.privateDoc.data.privateKey

    getMasterKey: ->
      @user.masterKey

    getRootFolderId: ->
      @user.privateDoc.data.rootId

    isConnected: ->
      @user.login?

    isConnected: ->
      @user? and @user.login?

    save: (key, value) ->
      @user.session[key] = value

    get: (key) ->
      if @user.prefs.hasOwnProperty(key)
        return @user.prefs[key]
      else
        return null

    set: (key, value) ->
      @user.prefs[key] = value
      @save()

    save: () ->
      tmpDoc = angular.copy(@user.privateDoc)
      crypto.encryptDataField(@getMasterKey(), tmpDoc)
      .then =>
        storage.save(tmpDoc).then (result) =>
          @user.privateDoc._rev = result.rev

    saveFlash: (key, value) ->
      @flash[key] = value

    getFlash: (key) ->
      if @flash.hasOwnProperty(key)
        value = angular.copy(@flash[key])
        delete @flash[key]
        return value
      else
        return null
  }
