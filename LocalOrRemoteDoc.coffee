angular.module('lupo-proto').
factory('LocalOrRemoteDoc', ->
  remoteDb = new PouchDB('localhost:5984/lupo-proto')
  localDb = new PouchDB('lupo-proto')
  {
    get: (_id) =>
      topDeferred = localDb.get(_id).then
        (doc) =>
          topDeferred.resolve(doc)
        ,
        (err) =>
          remoteDb.get(_id).then
            (doc) =>
              topDeferred.resolve(doc)
            ,
            (err) =>
              topDeferred.reject(err)
    ,
    put: (doc) =>
      topDeferred = localDb.put(doc).then
        =>
          remoteDb.put(doc).then
            =>
              topDeferred.resolve("success")
            ,
            (err) =>
              topDeferred.reject('distant failure: ' + err)
        ,
        (err) =>
          topDeferred.reject('local failure: ' + err)
  }