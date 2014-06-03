angular.module('fileManager').
factory 'File', ($q, assert, crypto, session, User, storage, cache) ->
  #TMP
  TYPE_FOLDER = 0
  TYPE_FILE = 1
  class File
    constructor: (pObj) ->
      console.log "File", pObj
      @_id =       pObj._id
      @_rev =      pObj._rev
      @content =   pObj.content
      @metadata =  pObj.metadata
      #@contentId = pObj.contentId
      #@key =       pObj.key
      if pObj.data?
        if assert.tests.isAnArray(pObj.data) and not(@content?)
          @content = pObj.data
        else
          if assert.tests.isAnObject(pObj.data) and not(@metadata?)
            @metadata = pObj.data

    #
    # Class methods
    #

    @_getDoc: (id, key) ->
      _funcName = "_getDoc"
      console.debug _funcName, id
      assert.defined(id, "id", _funcName)
      unless key?
        key = session.getMasterKey()
      assert.defined(key, "key", _funcName)
      storage.get(id).then (doc) =>
        crypto.decryptDataField(key, doc)
        return doc

    @getFile: (id, key) ->
      _funcName = "@getFile"
      console.log _funcName, id
      assert.defined id, "id",  _funcName
      File._getDoc(id, key)
      .then (metadataDoc) =>
        assert.defined metadataDoc, "metadataDoc", _funcName
        file = new File(metadataDoc)
        assert.defined metadataDoc.data, "metadataDoc.data", _funcName
        if metadataDoc.data.contentId?
          File._getDoc(metadataDoc.data.contentId, key)
          .then (contentDoc) =>
            assert.defined contentDoc,      "contentDoc",      _funcName
            assert.defined contentDoc.data, "contentDoc.data", _funcName
            file.content = contentDoc.data
            return file
        else
          # it is a contentDoc
          console.log "no metadata but content", file
          return file

    @getContent: (id, key) ->
      console.log "getContent", id
      assert.defined id, "id", "getContent"
      File.getFile(id, key).then (file) =>
        assert.defined file,         "file",         "getContent"
        assert.defined file.content, "file.content", "getContent"
        return file.content

    @getMetadata: (id, key) ->
      console.log "getMetadata", id
      assert.defined id, "id",  "getMetadata"
      File._getDoc(id, key).then(
        (doc) =>
          assert.defined doc,      "doc",      "getMetadata"
          assert.defined doc.data, "doc.data", "getMetadata"
          return new File(doc)
      )

    #
    # Private methods
    #

    _preventConflict: (doc) ->
      #TODO: replace @ by a conflict handler
      _funcName = "_preventConflict"
      console.log _funcName, doc
      deferred = $q.defer()
      if doc._id?
        @getLastRev().then (_rev) =>
          doc._rev = _rev
          deferred.resolve(doc)
      else
        deferred.resolve(doc)
      return deferred.promise

    _saveDoc: (doc, key) ->
      _funcName = "_saveDoc"
      console.debug _funcName, doc
      assert.defined(doc, "doc", _funcName)
      unless key?
        key = session.getMasterKey()
      assert.defined(key, "key", _funcName)
      crypto.encryptDataField(key, doc)
      storage.save(doc)

    #
    # Public methods
    #

    isFolder: () ->
      if @content?
        return assert.tests.isAnArray(@content)
      if @metadata?
        return @metadata.type == TYPE_FOLDER

    addToFolder: (folderId, key) ->
      _funcName = "addToFolder"
      console.log _funcName, folderId
      assert.defined @_id,     "@_id",     _funcName
      assert.defined folderId, "folderId", _funcName
      File.getFile(folderId, key).then (folder) =>
        assert.array folder.content, "folder.content", _funcName
        folder.content.push(@_id)
        folder.saveContentAndMetadata(key).then =>
          @metadata.parentId = folderId
          #TODO: change @ to a triggered update via changes watcher
          cache.expire(folder._id, "content")
          folder.listContent(key)
          @saveMetadata(key)

    removeFromFolder: (key) ->
      _funcName = "removeFromFolder"
      console.log _funcName
      assert.defined @_id, "@_id", _funcName
      assert.defined @metadata.parentId, "@metadata.parentId", _funcName
      File.getFile(@metadata.parentId, key).then (folder) =>
        assert.array folder.content, "folder.content", _funcName
        folder.content.splice(
          folder.content.indexOf(@_id)
          1
        )
        folder.saveContentAndMetadata(key).then =>
          #TODO: change @ to a triggered update via changes watcher
          cache.expire(folder._id, "content")
          folder.listContent(key)
          return @

    getLastRev: (key) ->
      _funcName = "getLastRev"
      console.log _funcName, @_id
      assert.defined @_id, "@_id", _funcName
      File.getMetadata(@_id, key).then (content) =>
        content._rev

    save: (key) ->
      _funcName = "save"
      console.log _funcName
      if @content?
        @saveContentAndMetadata(key).then =>
          return @
      else
        if @metadata?
          @saveMetadata(key).then =>
            return @

    saveMetadata: (key) ->
      _funcName = "saveMetadata"
      console.log _funcName
      metadataDoc = {
        _id: @_id
        _rev: @_rev
        data: @metadata
      }
      @_preventConflict(metadataDoc).then (metadataDoc) =>
      @_saveDoc(metadataDoc, key).then (result) =>
        @_id = result.id
        @_rev = result.rev
        return @

    saveContentAndMetadata: (key) ->
      _funcName = "saveContentAndMetadata"
      console.log _funcName
      content = {
        data: @content
      }
      if @metadata?
        content._id = if @metadata.contentId? then @metadata.contentId
      else
        content._id = if @_id then @_id
        content._rev = if @_rev then @_rev
      @_preventConflict(content).then (content) =>
        @_saveDoc(content, key).then (contentResult) =>
          unless @metadata?
            @_id = contentResult.id
            @_rev = contentResult.rev
            return @
          assert.unchanged(contentResult.id, @metadata.contentId,
            "contentResult.id", "@metadata.contentId", _funcName)
          @metadata.contentId = contentResult.id
          @saveMetadata(key)

    listContent: (key) ->
      _funcName = "listContent"
      console.log _funcName, @_id
      assert.defined @_id, "@_id", _funcName
      deferred = $q.defer()
      inProgess = []
      list = cache.get(@_id, "content")
      if list?
        deferred.resolve(list)
      else
        File.getContent(@_id, key).then (content) =>
          assert.array content, "content", _funcName
          list = []
          atLeastOne = false
          for element in content
            if element?
              atLeastOne = true
              inProgess.push(null)
              File.getMetadata(element, key).then(
                (file) =>
                  assert.defined file,               "file",              _funcName
                  assert.defined file.metadata,      "file.metadata",      _funcName
                  assert.defined file.metadata.name, "file.metadata.name", _funcName
                  assert.defined file.metadata.type, "file.metadata.type", _funcName
                  #file.name = file.metadata.name
                  #file.type = file.metadata.type

                  if file.isFolder()
                    file.content = []
                  else
                    assert.defined file.metadata.size, "file.metadata.size", _funcName
                    #file.size = file.metadata.size
                  list.push(file)
                  inProgess.pop()
                (err) =>
                  inProgess.pop()
              )
              .then =>
                if inProgess.length == 0
                  # if all deferred are terminated #
                  console.debug "list", list
                  cache.store(@_id, "content", list)
                  deferred.resolve(list)
          unless atLeastOne
            deferred.resolve([])
      return deferred.promise

    rename: (newName) ->
      _funcName = 'rename'
      console.log _funcName, newName
      assert.defined newName, "newName", _funcName
      @getLastRev().then (_rev) =>
        @_rev = _rev
        @metadata.name = newName
        @saveMetadata()

    move: (newParentId, key) ->
      _funcName = 'move'
      console.log _funcName, @metadata.parentId, newParentId
      assert.defined newParentId,   "newParentId",   _funcName
      assert.defined @metadata.parentId, "@parentId", _funcName
      File.getFile(@metadata.parentId, key).then (currentParent) =>
        assert.array currentParent.content, "currentParent.content", _funcName
      @removeFromFolder(key).then =>
        @addToFolder(newParentId, key). then(
          =>
            @metadata.parentId = newParentId
            @saveMetadata()
          (err) =>
            # roll back
            console.error("move roll back")
            @addToFolder(@metadata.parentId, key)
        )

    share: (username) ->
      _funcName = "share"
      console.log _funcName, username
      assert.defined username, "username", _funcName
      User.getByName(username).then (user) =>
        console.log "user", user.rows[0]
