angular.module('fileManager').
factory('fileManager', ($q, assert, crypto, session, storage, cache, File) ->
  TYPE_FOLDER = 0
  TYPE_FILE = 1

  fm = {
    _createFile: (name, content, type, parentId, key) ->
      _funcName = "_createFile"
      console.log _funcName, name, content, parentId
      assert.defined name,     "name",     _funcName
      assert.defined content,  "content",  _funcName
      assert.defined type,     "type",     _funcName
      assert.defined parentId, "parentId", _funcName
      new File({_id: parentId}).listContent(key).then(
        (list) =>
          console.log "list", list
          assert.defined list, "list", _funcName
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

    createFile: (name, content, parentId, key) ->
      _funcName = "createFile"
      console.log _funcName, name, content, parentId
      assert.defined name,     "name",     _funcName
      assert.defined content,  "content",  _funcName
      assert.defined parentId, "parentId", _funcName
      this._createFile(name, content, TYPE_FILE, parentId, key)

    createFolder: (name, parentId, key) ->
      console.log "createFolder", name, parentId
      assert.defined name,     "name",     "createFolder"
      assert.defined content,  "content",  "createFolder"
      assert.defined parentId, "parentId", "createFolder"
      this._createFile(name, [], TYPE_FOLDER, parentId, key)

    createRootFolder: (masterKey) ->
      console.log "createRootFolder"
      assert.defined masterKey, "masterKey", "createRootFolder"
      new File({content: []}).save(masterKey)
      .then (root) =>
        console.log "root", root
        this.createFile("README", "Welcome", root._id, masterKey)
        this.createFolder("Shares", root._id, masterKey)
        return root._id

    instance: {
      history:  []
      current:  -1
      watchers: []

      goForward: (toId) ->
        console.log "goForward", toId
        assert.defined this.current, "this.current", "goForward"
        assert.defined this.history, "this.history", "goForward"
        assert.custom(
          this.current < this.history.length
          "<goForward> this.current >= this.history.length")
        if this.current + 1 >= this.history.length
          unless toId?
            return

        folderId = if toId then toId else this.history[this.current + 1]
        folder = new File({_id: folderId})
        folder.listContent().then (list) =>
          assert.defined list, "list", "goForward"
          this.fileTree = list
          this.current += 1
          if toId?
            delete this.history[this.current..]
            this.history[this.current] = toId
          this.notifyWatchers()

      goBackward: ->
        console.log "goBackward"
        assert.defined this.current, "this.current", "goBackward"
        if this.current > -1
          this.current -= 1
          this.notifyWatchers()

      goToFolder: (file) ->
        console.log "goToFolder", file
        assert.defined file, "file", "goToFolder"
        assert.defined file.isFolder, "file.isFolder", "goToFolder"
        if file.isFolder()
          assert.defined file.id, "file.id", "goToFolder"
          this.goForward(file.id)

      currentId: ->
        assert.defined this.current, "this.current", "currentId"
        assert.defined this.history, "this.history", "currentId"
        console.log "currentId", this.history[this.current]
        this.history[this.current]

      addWatcher: (callback) ->
        assert.defined this.watchers, "this.watchers", "addWatcher"
        this.watchers.push(callback)

      notifyWatchers: ->
        console.log "notifyWatchers"
        assert.defined this.watchers, "this.watchers", "addWatcher"
        for watcher in this.watchers
          watcher.call()

      addFile: (metadata, content) ->
        _funcName = 'addFile'
        console.log _funcName, metadata
        assert.defined metadata.name, "metadata.name", _funcName
        assert.defined content, "content", _funcName
        fm.createFile(metadata.name, content, this.currentId())
        .then (file) =>
          this.fileTree.push file

      createFile: ->
        console.log "createFile", this
        basename = "new document"
        i = 0
        name = basename
        assert.defined this.fileTree, "this.fileTree", "createFile"
        assert.array this.fileTree, "this.fileTree", "createFile"
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
        assert.defined this.fileTree, "this.fileTree", "createFolder"
        assert.array this.fileTree, "this.fileTree", "createFolder"
        while name in (f.name for f in this.fileTree)
          i += 1
          name = basename + " " + i
        fm.createFolder(name, this.currentId())
        .then (folder) =>
          this.fileTree.push folder

    }

    getInstance: (path, scope, scopeVar, watcher) ->
      _funcName = "getInstance"
      console.log _funcName, path
      if path is "" or path is "/"
        folderId = session.getRootFolder()
      else
        folderId = path[1..]
      assert.defined folderId, "folderId", _funcName
      this.instance.goForward(folderId).finally(
        =>
          console.log "moved to folderId"
          unless scope[scopeVar]?
            scope[scopeVar] = this.instance
          #this.instance.addWatcher(watcher)
          #FIXME: why notify is needed by FileDirective and not Tree??
          this.instance.notifyWatchers()
        (err) =>
          console.error(err)
      )
      return this.instance
  }
)
