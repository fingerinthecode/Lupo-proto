angular.module('session')
.factory 'User', (assert, storage) ->
  class User
    constructor: (login, username, masterKey, privateKey, publicKey, rootFolder) ->
      console.log "User", login, username
      @public = {}
      @private = {}
      @public.username    = username
      @private.login      = login
      @private.masterKey  = masterKey
      @private.privateKey = privateKey
      @private.publicKey  = publicKey
      @private.rootFolder = rootFolder

    @getByName: (username = '') ->
      _funcName = "getByName"
      console.log _funcName, username
      assert.defined username, "username", _funcName
      #storage.getView 'users',
      storage.query(
        "proto/getUserByName"
        {
          key: username
        }
      )
