angular.module('session')
.factory 'User', (assert, storage) ->
  class User
    constructor: (@username, @publicKey, @login, @masterKey, @privateDoc) ->
      console.log "User", login, username
      @prefs = @privateDoc.data.prefs

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
