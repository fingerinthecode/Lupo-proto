angular.module('session')
.factory 'User', (assert, storage) ->
  class User
    constructor: (@username, @publicKey, @login, @masterKey, @privateKey, @rootFolderId) ->
      console.log "User", login, username, @masterkey
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

    @all: ->
      storage.queryRemote("proto/getUserByName")