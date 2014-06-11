angular.module('lupo-proto').
factory('storage', ($q, $location, assert, pouchdb) ->
  dbUrl = $location.absUrl().split('#')[0]
  dbUrl += 'lupo-proto/'
  remoteDb = new PouchDB(dbUrl)
  #localDb = new PouchDB('lupo-proto')
  #TMP
  #PouchDB.replicate(localDb, remoteDb, {live: true})
  #.on('change', (e) -> console.log("upload", e))
  #.on('complete', (e) -> console.log("upload", e))
  #.on('error', (e) -> console.error("upload", e))
  syncIds = {list: []}
  ###
  localDb.allDocs().then (list) =>
    syncIds.list = (row.id for row in list.rows)
    syncIds.list.push "proto"
    PouchDB.replicate(localDb, remoteDb,
      live: true
    )
    .on 'change', (change) =>
      #syncIds.list.push result.id
      console.log "local change", change
    .on('complete', (e) -> console.log("complete", e))
    .on('uptodate', (e) -> console.log("uptodate", e))
    .on('error', (e) -> console.error("error", e))
    remoteDb.change(
      live: true
    ).on 'change', (change) =>
      console.log "remote change", change
      if syncIds.indexOf(change.id) > -1
        console.log "remote change!!"
  ###
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
      console.log _funcName, _id
      deferred = $q.defer()
      remoteDb.get _id, (err, result) =>
        if err?
          console.error "NOT FOUND", _id, err
          deferred.reject err
        else
          deferred.resolve result
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
      otherOneFailed = false
      remoteDb.query fun, options, (err, result) =>
        if result.rows.length == 0
          deferred.resolve []
        else
          deferred.resolve (doc.value for doc in result.rows)
      return deferred.promise
  }
)
