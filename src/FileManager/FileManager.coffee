angular.module('fileManager').
factory('fileManager', ($q, crypto, session, storage) ->
  TYPE_FOLDER = 0
  TYPE_FILE = 1

  isAnArray = (element) ->
    {}.toString.call(element) is '[object Array]'

  isAnObject = (element) ->
    {}.toString.call(element) is '[object Object]'

  assertDefined = (variable, varName, funcName) ->
    assert variable?, "<" + funcName + "> " + varName + " is not defined"

  assertIsArray = (variable, varName, funcName) ->
    assert isAnArray(variable), "<" + funcName + "> " + varName + " is not an array"

  assertUnchanged = (newVal, oldVal, newVarName, oldVarName, funcName) ->
    if oldVal?
      assert(newVal == oldVal, "<" + funcName + "> " + oldVarName + "/" + newVarName +
        " has changed (" + oldVal + "/" + newVal + ")")

  File = (pObj) ->
    obj = {
      _id:       pObj._id
      _rev:      pObj._rev
      content:   pObj.content
      metadata:  pObj.metadata
      contentId: pObj.contentId
      key:       pObj.key

      isFolder: () ->
        if this.content?
          return isAnArray(this.content)
        if this.metadata?
          return this.metadata.type == TYPE_FOLDER

      rename: (newName) ->
        _funcName = 'rename'
        console.log _funcName, newName
        assertDefined newName, "newName", _funcName
        fm.getLastRev(this._id).then (_rev) =>
          this._rev = _rev
          this.metadata.name = newName
          this.saveMetadata()

      move: (newParentId, key) ->
        _funcName = 'move'
        console.log _funcName, this.metadata.parentId, newParentId
        assertDefined newParentId,   "newParentId",   _funcName
        assertDefined this.metadata.parentId, "this.parentId", _funcName
        fm.getFile(this.metadata.parentId, key).then (currentParent) =>
          assertIsArray currentParent.content, "currentParent.content", _funcName
        this.removeFromFolder(key).then =>
          this.addToFolder(newParentId, key). then(
            =>
              this.metadata.parentId = newParentId
              this.saveMetadata()
            (err) =>
              # roll back
              console.error("move roll back")
              this.addToFolder(this.metadata.parentId, key)
          )

      addToFolder: (folderId, key) ->
        _funcName = "addToFolder"
        console.log _funcName, folderId
        assertDefined this._id, "this._id", _funcName
        assertDefined folderId, "folderId", _funcName
        fm.getFile(folderId, key).then (folder) =>
          assertIsArray folder.content, "folder.content", _funcName
          folder.content.push(this._id)
          folder.saveContent(key).then =>
            this.metadata.parentId = folderId
            #TODO: change this to a triggered update via changes watcher
            fm._cache.expire(folder._id, "content")
            fm.listFolderContent(folder._id, key)
            this.saveMetadata(key)

      removeFromFolder: (key) ->
        _funcName = "removeFromFolder"
        console.log _funcName
        assertDefined this._id, "this._id", _funcName
        assertDefined this.metadata.parentId, "this.metadata.parentId", _funcName
        fm.getFile(this.metadata.parentId, key).then (folder) =>
          assertIsArray folder.content, "folder.content", _funcName
          folder.content.splice(
            folder.content.indexOf(this._id)
            1
          )
          folder.saveContent(key).then =>
            #TODO: change this to a triggered update via changes watcher
            fm._cache.expire(folder._id, "content")
            fm.listFolderContent(folder._id, key)
            return this

      _saveHelper: (doc) ->
        _funcName = "_saveHelper"
        console.log _funcName
        #TODO: replace this by a conflict handler


      _preventConflict: (doc) ->
        deferred = $q.defer()
        if doc._id?
          fm.getLastRev(doc._id).then (_rev) =>
            doc._rev = _rev
            deferred.resolve(doc)
        else
          deferred.resolve(doc)
        return deferred.promise

      save: (key) ->
        _funcName = "save"
        console.log _funcName
        if this.content?
          this.saveContent(key).then =>
            return this
        else
          if this.metadata?
            this.saveMetadata(key).then =>
              return this


      saveMetadata: (key) ->
        _funcName = "saveMetadata"
        console.log _funcName
        metadataDoc = {
          _id: this._id
          _rev: this._rev
          data: this.metadata
        }
        this._preventConflict(metadataDoc).then (metadataDoc) =>
        fm.saveMetadata(metadataDoc, key).then (result) =>
          this._id = result.id
          this._rev = result.rev
          return this

      saveContent: (key) ->
        _funcName = "saveContent"
        console.log _funcName
        content = {
          data: this.content
        }
        if this.metadata?
          content._id = if this.metadata.contentId? then this.metadata.contentId
        else
          content._id = if doc._id then doc._id
          content._rev = if doc._rev then doc._rev
        this._preventConflict(content).then (content) =>
          fm.saveContent(content, key).then (contentResult) =>
            unless this.metadata?
              this._id = contentResult._id
              this._rev = contentResult._rev
              return this
            assertUnchanged(contentResult.id, this.metadata.contentId,
              "contentResult.id", "this.metadata.contentId", _funcName)
            this.metadata.contentId = contentResult.id
            this.saveMetadata(key)


      toDoc: () ->
        {
          _id:       this._id
          _rev:      this._rev
          content:   this.content
          metadata:  this.metadata
          contentId: this.contentId
        }
    }
    if pObj.data?
      if isAnArray(pObj.data) and not(obj.content?)
        obj.content = pObj.data
      else
        if isAnObject(pObj.data) and not(obj.metadata?)
          obj.metadata = pObj.data
    return obj



  fm = {
    _cache: {
      _data: {}

      get: (id, type) ->
        if this._data[id]?
          return this._data[id][type]

      store: (id, type, value) ->
        unless this._data[id]?
          this._data[id] = {}
        this._data[id][type] = value

      expire: (id) ->
        delete this._data[id]

      #TODO: watcher of changes
    }
    _getFileContent: (id, key) ->
      console.debug "_getFileContent", id
      assertDefined(id, "id", "_getFileContent")
      unless key?
        key = session.getMasterKey()
      assert(key?, "key is undefined")
      storage.get(id).then (doc) =>
        crypto.decryptDataField(key, doc)
        return doc

    _getFileMetadata: (id, key) ->
      console.debug "_getFileMetadata", id
      assertDefined(id, "id", "_getFileMetadata")
      this._getFileContent(id, key)

    saveContent: (doc, key) ->
      console.debug "saveContent", doc
      assertDefined(doc, "doc", "saveContent")
      unless key?
        key = session.getMasterKey()
      assert(key?, "key is undefined")
      crypto.encryptDataField(key, doc)
      storage.save(doc)

    saveMetadata: (doc, key) ->
      console.debug "saveMetadata", doc
      assertDefined(doc, "doc", "saveMetadata")
      this.saveContent(doc, key)

    _createFile: (name, content, type, parentId, key) ->
      _funcName = "_createFile"
      console.log _funcName, name, content, parentId
      assertDefined name,     "name",     _funcName
      assertDefined content,  "content",  _funcName
      assertDefined type,     "type",     _funcName
      assertDefined parentId, "parentId", _funcName
      this.listFolderContent(parentId, key).then(
        (list) =>
          console.log "list", list
          assertDefined list, "list", _funcName
          unless name in [f.metadata.name for f in list]
            content = if content? then content else ""
            newFile = new File {
              content: content
              metadata: {
                type: type
                name: name
                size: if type != TYPE_FOLDER then content.length
              }
            }
            newFile.save(key)
            .then (result) =>
              newFile.addToFolder(parentId, key)

        (err) =>
          return "parent does not exist"
      )

    getLastRev: (id, key) ->
      this._getFileMetadata(id, key).then (content) =>
        return content._rev

    getFile: (id, key) ->
      console.log "getFile", id
      assertDefined id, "id",  "getFile"
      this._getFileMetadata(id, key)
      .then (metadataDoc) =>
        assertDefined metadataDoc, "metadataDoc", "getFile"
        file = new File(metadataDoc)
        assertDefined metadataDoc.data, "metadataDoc.data", "getFile"
        if metadataDoc.data.contentId?
          this._getFileContent(metadataDoc.data.contentId)
          .then (contentDoc) =>
            assertDefined contentDoc,      "contentDoc",      "getFile"
            assertDefined contentDoc.data, "contentDoc.data", "getFile"
            file.content = contentDoc.data
            return file
        else
          # it is a contentDoc
          console.log "not metadata but content"
          return file

    getContent: (id, key) ->
      console.log "getContent", id
      assertDefined id, "id", "getContent"
      this.getFile(id, key).then (file) =>
        assertDefined file, "file",  "getContent"
        assertDefined file.content, "file.content", "getContent"
        return file.content

    getMetadata: (id, key) ->
      console.log "getMetadata", id
      assertDefined id, "id",  "getMetadata"
      this._getFileMetadata(id, key).then(
        (doc) =>
          assertDefined doc, "doc",  "getMetadata"
          assertDefined doc.data, "doc.data", "getMetadata"
          return new File(doc)
      )

    listFolderContent: (id, key) ->
      console.log "listFolderContent", id
      assertDefined id, "id", "listFolderContent"
      deferred = $q.defer()
      inProgess = []
      list = this._cache.get(id, "content")
      if list?
        deferred.resolve(list)
      else
        this.getContent(id).then (content) =>
          assertIsArray content, "content", "listFolderContent"
          list = []
          atLeastOne = false
          for element in content
            if element?
              atLeastOne = true
              inProgess.push(null)
              this.getMetadata(element).then(
                (file) =>
                  assertDefined file,               "file",              "listFolderContent"
                  assertDefined file.metadata,      "file.metadata",      "listFolderContent"
                  assertDefined file.metadata.name, "file.metadata.name", "listFolderContent"
                  assertDefined file.metadata.type, "file.metadata.type", "listFolderContent"
                  file.name = file.metadata.name
                  file.type = file.metadata.type

                  if file.isFolder()
                    file.content = []
                  else
                    assertDefined file.metadata.size, "file.metadata.size", "listFolderContent"
                    file.size = file.metadata.size
                  list.push(file)
                  inProgess.pop()
                (err) =>
                  inProgess.pop()
              )
              .then =>
                if inProgess.length == 0
                  # if all deferred are terminated #
                  console.debug "list", list
                  this._cache.store(id, "content", list)
                  deferred.resolve(list)
          unless atLeastOne
            deferred.resolve([])
      return deferred.promise

    createFile: (name, content, parentId, key) ->
      _funcName = "createFile"
      console.log _funcName, name, content, parentId
      assertDefined name,     "name",     _funcName
      assertDefined content,  "content",  _funcName
      assertDefined parentId, "parentId", _funcName
      this._createFile(name, content, TYPE_FILE, parentId, key)

    createFolder: (name, parentId, key) ->
      console.log "createFolder", name, parentId
      assertDefined name,     "name",     "createFolder"
      assertDefined content,  "content",  "createFolder"
      assertDefined parentId, "parentId", "createFolder"
      this._createFile(name, [], TYPE_FOLDER, parentId, key)

    createRootFolder: (masterKey) ->
      console.log "createRootFolder"
      assertDefined masterKey, "masterKey", "createRootFolder"
      root = new File({content: []}).save(masterKey)
      .then (result) =>
        this.createFile("README", "Welcome", root._id, masterKey)
        this.createFolder("Shares", root._id, masterKey)
        return root._id

    instance: {
      history:  []
      current:  -1
      watchers: []

      goForward: (toId) ->
        console.log "goForward", toId
        assertDefined this.current, "this.current", "goForward"
        assertDefined this.history, "this.history", "goForward"
        assert this.current < this.history.length, "<goForward> this.current >= this.history.length"
        if this.current + 1 >= this.history.length
          unless toId?
            return

        folderId = if toId then toId else this.history[this.current + 1]

        fm.listFolderContent(folderId).then (list) =>
          assertDefined list, "list", "goForward"
          this.fileTree = list
          this.current += 1
          if toId?
            delete this.history[this.current..]
            this.history[this.current] = toId
          this.notifyWatchers()

      goBackward: ->
        console.log "goBackward"
        assertDefined this.current, "this.current", "goBackward"
        if this.current > -1
          this.current -= 1
          this.notifyWatchers()

      goToFolder: (file) ->
        console.log "goToFolder", file
        assertDefined file, "file", "goToFolder"
        assertDefined file.isFolder, "file.isFolder", "goToFolder"
        if file.isFolder()
          assertDefined file.id, "file.id", "goToFolder"
          this.goForward(file.id)

      currentId: ->
        assertDefined this.current, "this.current", "currentId"
        assertDefined this.history, "this.history", "currentId"
        console.log "currentId", this.history[this.current]
        this.history[this.current]

      addWatcher: (callback) ->
        assertDefined this.watchers, "this.watchers", "addWatcher"
        this.watchers.push(callback)

      notifyWatchers: ->
        console.log "notifyWatchers"
        assertDefined this.watchers, "this.watchers", "addWatcher"
        for watcher in this.watchers
          watcher.call()

      addFile: (metadata, content) ->
        _funcName = 'addFile'
        console.log _funcName, metadata
        assertDefined metadata.name, "metadata.name", _funcName
        assertDefined content, "content", _funcName
        fm.createFile(metadata.name, content, this.currentId())
        .then (file) =>
          this.fileTree.push file

      createFile: ->
        console.log "createFile", this
        basename = "new document"
        i = 0
        name = basename
        assertDefined this.fileTree, "this.fileTree", "createFile"
        assertIsArray this.fileTree, "this.fileTree", "createFile"
        while name in (f.name for f in this.fileTree)
          i += 1
          name = basename + " " + i
        fm.createFile(name, "", this.currentId())
        .then (file) =>
          this.fileTree.push file

      createFolder: ->
        console.log "createFolder"
        basename = "new folder"
        i = 0
        name = basename
        assertDefined this.fileTree, "this.fileTree", "createFolder"
        assertIsArray this.fileTree, "this.fileTree", "createFolder"
        while name in (f.name for f in this.fileTree)
          i += 1
          name = basename + " " + i
        fm.createFolder(name, this.currentId())
        .then (folder) =>
          this.fileTree.push folder

    }

    getInstance: (path, scope, scopeVar, watcher) ->
      console.log "getInstance", path
      if path is "" or path is "/"
        folderId = session.getRootFolder()
      else
        folderId = path[1..]
      assertDefined folderId, "folderId", "init"
      this.instance.goForward(folderId).then =>
        console.log "moved to folderId"
        unless scope[scopeVar]?
          scope[scopeVar] = this.instance
        #this.instance.addWatcher(watcher)
        #FIXME: why notify is needed by FileDirective and not Tree??
        this.instance.notifyWatchers()
      return this.instance
  }
)
