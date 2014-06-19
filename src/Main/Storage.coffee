angular.module('lupo-proto').
factory('storage', ($q, $location, assert, db) ->
  dbUrl = $location.absUrl().split('#')[0]
  dbUrl += 'lupo-proto/'
  remoteDb = new db(dbUrl)
  _indent = "  "
  {
    purge: (db) ->
      if not db?
        @purge(localDb).then =>
          @purge(remoteDb)
      else
        db.allDocs().then (list) =>
          for row in list.rows
            db.remove({_id: row.id, _rev: row.value.rev})
            .then =>
              console.log "remove", row.id
            .catch =>
              console.error "error removing", row.id

    get: (_id) ->
      _funcName = _indent + "storage.get"
      deferred = $q.defer()
      remoteDb.get _id
      .then (result) =>
        deferred.resolve result
      .catch (err) =>
        console.error "NOT FOUND", _id, err
        deferred.reject err
      return deferred.promise

    _save: (doc) ->
      deferred = $q.defer()
      if doc._id?
        method = "put"
      else
        method = "post"
        delete doc._id
        delete doc._rev
      console.log method, doc
      remoteDb[method](doc)
      .then (result) =>
        deferred.resolve(result)
      .catch (err) =>
        console.error(err, method)
        deferred.reject(err)
      return deferred.promise

    saveLocal: (doc) ->
      _funcName = _indent + "storage.saveLocal"
      console.log _funcName
      @_save doc

    saveRemoteOnly: (doc) ->
      _funcName = _indent + "storage.saveRemoteOnly"
      console.log _funcName
      @_save doc

    save: (doc) ->
      @_save(doc)

    del: (doc) ->
      deletedDoc = {_id: doc._id, _rev: doc._rev, _deleted: true}
      @save(deletedDoc)

    query: (fun, options) ->
      _funcName = _indent + "query"
      console.log _funcName, fun, options
      deferred = $q.defer()
      otherOneFailed = false
      remoteDb.query fun, options
      .then (result) ->
        if result.rows.length == 0
          deferred.resolve []
        else
          deferred.resolve (doc.value for doc in result.rows)
      .catch (error) ->
        deferred.reject error
      return deferred.promise
  }
)
