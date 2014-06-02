angular.module('lupo-proto').
factory('storage', ($q, pouchdb) ->
  remoteDb = new PouchDB('http://localhost:5984/lupo-proto')
  localDb = new PouchDB('lupo-proto')
  PouchDB.sync(localDb, remoteDb, {
    live: true
  }).on('change', (e) -> console.log(e))
  .on('complete', (e) -> console.log(e))
  .on('error', (e) -> console.error(e))

  {
    get: (_id) ->
      deferred = $q.defer()
      localDb.get(_id)
      .then((result) =>
        deferred.resolve(result)
      ).catch (err) =>
        deferred.reject(err)
      return deferred.promise
    ,
    save: (doc) ->
      deferred = $q.defer()
      method = if doc._id? then "put" else "post"
      console.log method, doc
      localDb[method](doc)
      .then((result) =>
        deferred.resolve(result)
      ).catch (err) =>
        console.error(err)
        deferred.reject(err)
      return deferred.promise

    query: (fun, options) ->
      deferred = $q.defer()
      localDb.query fun, options
      .then (result) =>
        deferred.resolve result
      .catch (err) =>
        deferred.reject err
      return deferred.promise
  }
)