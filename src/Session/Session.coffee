angular.module('session')
.factory 'session', ->
  {
    user: {}

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
  }