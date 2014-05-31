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

      isFolder: () ->
        if this.content?
          return isAnArray(this.content)
        if this.metadata?
          return this.metadata.type == TYPE_FOLDER

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

    _saveFileOrFolderContent: (doc, key) ->
      console.debug "_saveFileOrFolderContent", doc
      assertDefined(doc, "doc", "_saveFileOrFolderContent")
      unless key?
        key = session.getMasterKey()
      assert(key?, "key is undefined")
      crypto.encryptDataField(key, doc)
      storage.save(doc)

    _saveFileOrFolderMetadata: (doc, key) ->
      console.debug "_saveFileOrFolderMetadata", doc
      assertDefined(doc, "doc", "_saveFileOrFolderMetadata")
      this._saveFileOrFolderContent(doc, key)

    _saveFileOrFolder: (doc, key) ->
      _funcName = "_saveFileOrFolder"
      console.log _funcName, doc
      assertDefined doc,         "doc",         _funcName
      assertDefined doc.content, "doc.content", _funcName
      content = {
        data: doc.content
      }
      if doc.metadata?
        content._id = if doc.metadata.contentId then doc.metadata.contentId
        metadataDoc = {
          _id: doc._id
          _rev: doc._rev
          data: doc.metadata
        }
      else
        content._id = if doc._id then doc._id
        content._rev = if doc._rev then doc._rev
      subFunc = (content) =>
        this._saveFileOrFolderContent(content, key)
        .then (contentResult) =>
          assertDefined contentResult.id, "contentResult.id", _funcName
          unless metadataDoc?
            return contentResult
          assertUnchanged(contentResult.id, metadataDoc.data.contentId,
            "contentResult.id", "metadataDoc.data.contentId", _funcName)
          metadataDoc.data.contentId = contentResult.id
          this._saveFileOrFolderMetadata(metadataDoc, key).then (metadataResult) =>
            console.log "saved", metadataResult.id, "(contentId:", metadataResult.id, ")"
            assertDefined metadataResult.id, "metadataResult.id", _funcName
            return metadataResult
      if content._id
        this._getFileContent(content._id, key).then (oldContent) =>
          content._rev = oldContent._rev
          subFunc(content)
      else
        subFunc(content)

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

    _addFileToFolder: (fileId, folderId, key) ->
      console.log "_addFileToFolder", fileId, folderId
      assertDefined fileId,   "fileId",   "_addFileToFolder"
      assertDefined folderId, "folderId", "_addFileToFolder"
      this.getFile(folderId, key).then (folder) =>
        assertIsArray folder.content, "folder.content", "_addFileToFolder"
        folder.content.push(fileId)
        this._saveFileOrFolder(folder, key).then =>
          #TODO: change this to a triggered update via changes watcher
          this._cache.expire(folderId, "content")
          this.listFolderContent(folderId, key)
          return

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
            newFileDoc = {
              content: content
              metadata: {
                type: type
                name: name
                size: if type != TYPE_FOLDER then content.length
              }
            }
            this._saveFileOrFolder(newFileDoc, key)
            .then (result) =>
              assertDefined result, "result.id", _funcName
              this._addFileToFolder(result.id, parentId, key)

        (err) =>
          return "parent does not exist"
      )

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
      this._saveFileOrFolder({content: []}, masterKey)
      .then (result) =>
        assertDefined result,    "result",    "createRootFolder"
        assertDefined result.id, "result.id", "createRootFolder"
        this.createFile("README", "Welcome", result.id, masterKey)
        .then =>
          return result.id

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
        .then =>
          #TMP
          element = new File({
            name: name
            size: 0
            type: TYPE_FILE
            metadata: {
              name: name
              size: 0
              type: TYPE_FILE
            }
          })
          this.fileTree.push element

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
        .then =>
          #TMP
          element = new File({
            name: name
            type: TYPE_FOLDER
            content: []
            metadata: {
              name: name
              type: TYPE_FOLDER
            }
          })
          console.log element
          this.fileTree.push element
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
