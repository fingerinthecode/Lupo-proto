angular.module('lupo-proto').
factory 'DbDoc', ($q, assert, crypto, cache, storage) ->
  class DbDoc
    @get: (id) ->
      _funcName = "get"
      console.log _funcName, id
      assert.defined(id, "id", _funcName)
      cacheValue = cache.get(id, "doc")
      if cacheValue?
        return $q.when(cacheValue)
      storage.get(id)

    @getAndDecrypt: (id, key) ->
      _funcName = "getAndDecrypt"
      console.log _funcName, id
      DbDoc.get(id).then (doc) =>
        if crypto.isEncrypted(doc)
          return DbDoc.decryptDataField(doc, key)
        else
          return doc

    @encryptDataField: (doc, key) ->
      _funcName = "encryptDataField"
      assert.defined key, "key", _funcName
      assert.defined doc, "doc", _funcName
      assert.defined doc.data, "doc.data", _funcName
      crypto.symEncrypt(key, JSON.stringify(doc.data)).then (data) =>
        doc.data = data
        return doc

    @decryptDataField: (doc, key) ->
      _funcName = "decryptDataField"
      assert.defined key, "key", _funcName
      assert.defined doc, "doc", _funcName
      assert.defined doc.data, "doc.data", _funcName
      crypto.symDecrypt(key, doc.data).then (data) =>
        try
          doc.data = JSON.parse(data)
          cache.store(doc._id, "doc", doc)
          return doc
        catch
          throw "decrypt error"

    @save: (doc) ->
      storage.save(doc).then (retVal) =>
        cache.expire(doc._id, "doc")
        return retVal

    @encryptAndSave: (doc, key) ->
      _funcName = "encryptAndSave"
      console.log _funcName, doc, key
      assert.defined(key, "key", _funcName)
      cache.store(doc._id, "doc", doc)
      DbDoc.encryptDataField(doc, key)
      .then =>
        DbDoc.save(doc)

    @delete: (doc, key) ->
      _funcName = "delete"
      console.log _funcName, doc, key
      storage.del(doc).then (retVal) =>
        cache.expire(doc._id, "doc")
        return retVal
