angular.module('lupo-proto').
factory('storage', ($q, $location, assert, pouchdb) ->
  dbUrl = $location.absUrl().split('#')[0]
  dbUrl += 'lupo-proto/'
  remoteDb = new PouchDB(dbUrl)
  localDb = new PouchDB('lupo-proto')
  #TMP
  PouchDB.replicate(localDb, remoteDb)
  #.on('change', (e) -> console.log(e))
  #.on('complete', (e) -> console.log(e))
  #.on('error', (e) -> console.error(e))

  _indent = "  "
  {
    get: (_id) ->
      _funcName = _indent + "storage.get"
      console.log _funcName, _id
      deferred = $q.defer()
      otherOneFailed = false
      remoteDb.get _id, (err, result) =>
        if err?
          console.error "remote", err
          if otherOneFailed
            deferred.reject err
          otherOneFailed = true
        else
          deferred.resolve result
      localDb.get _id, (err, result) =>
        if err?
          console.error "local", err
          if otherOneFailed
            deferred.reject err
          otherOneFailed = true
        else
          deferred.resolve result
      return deferred.promise

    _save: (doc, remoteAndLocal) ->
      deferred = $q.defer()
      if doc._id?
        method = "put"
      else
        method = "post"
        delete doc._id
        delete doc._rev
      console.log method, doc
      (if remoteAndLocal
        localDb[method](doc)
      else
        remoteDb[method](doc)
      )
      .then (result) =>
        deferred.resolve(result)
      .catch (err) =>
        console.error(err, method)
        deferred.reject(err)
      return deferred.promise

    saveLocal: (doc) ->
      _funcName = _indent + "storage.saveLocal"
      console.log _funcName
      @_save doc, true

    saveRemoteOnly: (doc) ->
      _funcName = _indent + "storage.saveRemoteOnly"
      console.log _funcName
      @_save doc, false

    save: (doc) ->
      @_save(doc, true)

    del: (doc) ->
      deletedDoc = {_id: doc._id, _rev: doc._rev, _deleted: true}
      @saveLocal(deletedDoc).catch =>
        @saveRemoteOnly(deletedDoc)

    queryRemote: (fun, options) ->
      deferred = $q.defer()
      remoteDb.query fun, options, (err, result) =>
        if result.rows.length == 0
            deferred.resolve []
        else
          deferred.resolve (doc.value for doc in result.rows)
      return deferred.promise

    query: (fun, options) ->
      _funcName = _indent + "query"
      console.log _funcName, fun, options
      deferred = $q.defer()
      localDeferred = $q.defer()
      otherOneFailed = false
      localDb.query fun, options, (err, result) =>
        if result.rows.length == 0
          if otherOneFailed
            deferred.resolve []
          otherOneFailed = true
        else
          deferred.resolve (doc.value for doc in result.rows)
      remoteDb.query fun, options, (err, result) =>
        if result.rows.length == 0
          if otherOneFailed
            deferred.resolve []
          otherOneFailed = true
        else
          deferred.resolve (doc.value for doc in result.rows)
      return deferred.promise
  }
)