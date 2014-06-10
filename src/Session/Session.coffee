angular.module('session')
.factory 'session', (crypto) ->
  {
    user: {}
    vars:
      displayThumb: true
    flash: {}
    keyRing: {}

    registerKey: (key) ->
      keyId = crypto.getKeyIdFromKey(key)
      @keyRing[keyId] = key
      return keyId

    getKey: (keyId) ->
      @keyRing[keyId]

    getMainPublicKey: ->
      @user.publicKey

    getMainPrivateKey: ->
      @user.privateKey

    getMasterKey: ->
      @user.masterKey

    getRootFolderId: ->
      @user.rootFolderId

    isConnected: ->
      @user.login?

    isConnected: ->
      @user? and @user.login?

    save: (key, value) ->
      @user.session[key] = value

    get: (key) ->
      if @vars.hasOwnProperty(key)
        return @vars[key]
      else
        return null

    set: (key, value) ->
      @vars[key] = value
      #@save()

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
