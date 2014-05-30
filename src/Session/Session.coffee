angular.module('session')
.factory 'session', () ->
  {
    user: {
      public: {}
      private: {}
    }

    getMainPublicKey: ->
      this.user.private.publicKey

    getMainPrivateKey: ->
      this.user.private.privateKey

    getMasterKey: ->
      this.user.private.masterKey

    getRootFolder: ->
      this.user.private.rootFolder

    isConnected: ->
      this.user.private.login?

    registerSession: (login, username, masterKey, privateKey, publicKey, rootFolder) ->
      this.user.public.username    = username
      this.user.private.login      = login
      this.user.private.masterKey  = masterKey
      this.user.private.privateKey = privateKey
      this.user.private.publicKey  = publicKey
      this.user.private.rootFolder = rootFolder

    deleteSession: () ->
      delete this.user.public.username
      delete this.user.private.login
      delete this.user.private.masterKey
      delete this.user.private.privateKey
      delete this.user.private.publicKey
      delete this.user.private.rootFolder


  }