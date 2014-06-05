angular.module('session')
.factory 'User', (assert, storage) ->
  class User
    constructor: (@login, @username, @masterKey, @privateKey, @publicKey, @rootFolderId) ->
      console.log "User", login, username
      @keyRing = {}

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
