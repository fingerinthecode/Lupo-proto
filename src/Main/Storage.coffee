angular.module('lupo-proto').
factory('storage', ($q, pouchdb) ->
  remoteDb = pouchdb.create('localhost:5984/lupo-proto')
  localDb = pouchdb.create('lupo-proto')
  {
    get: (_id) =>
      deferred = $q.defer()
      localDb.get(_id)
      .then((result) =>
        deferred.resolve(result)
      ).catch (err) =>
        deferred.reject(err)
      return deferred.promise
    ,
    save: (doc) =>
      deferred = $q.defer()
      method = if doc._id? then "put" else "post"
      console.log method, doc
      localDb[method](doc)
      .then((result) =>
        console.log method, result
        assert(result?, "no reply from db")
        deferred.resolve(result)
      ).catch (err) =>
        console.error(err)
        deferred.reject(err)
      return deferred.promise
  }
)