angular.module('lupo-proto').
factory('storage', ($q, $location, assert, pouchdb) ->
  dbUrl = $location.absUrl().split('#')[0]
  dbUrl += 'lupo-proto/'
  remoteDb = new PouchDB(dbUrl)
  localDb = new PouchDB('lupo-proto')
  #TMP
  PouchDB.replicate(remoteDb, localDb)
  #PouchDB.sync(localDb, remoteDb, {
  #  live: true
  #}).on('change', (e) -> console.log(e))
  #.on('complete', (e) -> console.log(e))
  #.on('error', (e) -> console.error(e))

  _indent = "  "
  {
    get: (_id) ->
      _funcName = _indent + "storage.get"
      console.log _funcName, _id
      deferred = $q.defer()
      localDb.get(_id, (err, result) =>
        if err?
          console.error err
          deferred.reject err
        else
          deferred.resolve result
      )
      return deferred.promise

    save: (doc) ->
      _funcName = _indent + "storage.save"
      console.log _funcName
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
      _funcName = _indent + "query"
      console.log _funcName, fun, options
      deferred = $q.defer()
      localDb.query fun, options
      .then (result) =>
        deferred.resolve result
      .catch (err) =>
        console.error err
        deferred.reject err
      return deferred.promise
  }
)