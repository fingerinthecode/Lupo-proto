angular.module('session')
.factory 'session', ->
  {
    user: {}
    flash: {}

    getMainPublicKey: ->
      @user.private.publicKey

    getMainPrivateKey: ->
      @user.private.privateKey

    getMasterKey: ->
      @user.private.masterKey

    getRootFolder: ->
      @user.private.rootFolder

    isConnected: ->
      @user.private.login?

    isConnected: ->
      @user? and @user.private and @user.private.login?

    save: (key, value) ->
      @user.session[key] = value

    get: (key) ->
      if @user.session.hasOwnProperty(key)
        return @session[key]
      else
        return null

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
