angular.module('fileManager').
factory('Folder', (crypto, session, LocalOrRemoteDoc)->
  (id) =>
    {
      listContent: ->
        LocalOrRemoteDoc(id).then(
          (doc) =>
            return crypto.symDecrypt(session.masterKey, doc.data)
          ,
          (err) =>
            return "folder does not exist"
        )
      create: ->
    }
)
