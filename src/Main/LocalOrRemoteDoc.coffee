angular.module('lupo-proto').
factory('LocalOrRemoteDoc', ($q, pouchdb) ->
  remoteDb = pouchdb.create('localhost:5984/lupo-proto')
  localDb = pouchdb.create('lupo-proto')
  {
    get: (_id) =>
      #deferred = $q.defer()
      localDb.get(_id)
    ,
    put: (doc) =>
      #deferred = $q.defer()
      method = if doc._id? then "put" else "post"
      localDb[method](doc)
  }
)