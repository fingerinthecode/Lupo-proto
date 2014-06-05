angular.module('session')
.factory 'session', ->
  {
    user: {
      session: {}
      displayThumb: true
    }
    flash: {}

    getMainPublicKey: ->
      @user.publicKey

    getMainPrivateKey: ->
      @user.privateKey

    getMasterKey: ->
      @user.masterKey

    getRootFolder: ->
      @user.rootFolder

    isConnected: ->
      @user.login?

    isConnected: ->
      @user? and @user.login?

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
