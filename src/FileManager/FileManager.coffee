angular.module('fileManager').
factory('fileManager', ($q, assert, crypto, session, storage, cache, File, $stateParams) ->
  TYPE_FOLDER = 0
  TYPE_FILE = 1

  fm = {
    _createFile: (name, content, type, parentId, keyId) ->
      _funcName = "_createFile"
      console.info _funcName, name, content, parentId
      assert.defined name,     "name",     _funcName
      assert.defined content,  "content",  _funcName
      assert.defined type,     "type",     _funcName
      assert.defined parentId, "parentId", _funcName
      new File({_id: parentId, keyId: keyId}).listContent().then(
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
              keyId: keyId
            }
            newFile.save()
            .then (result) =>
              newFile.addToFolder(parentId)

        (err) =>
          return "parent does not exist"
      )

    createFile: (name, content, parentId, keyId) ->
      _funcName = "createFile"
      console.info _funcName, name, content, parentId
      assert.defined name,     "name",     _funcName
      assert.defined content,  "content",  _funcName
      assert.defined parentId, "parentId", _funcName
      this._createFile(name, content, TYPE_FILE, parentId, keyId)

    createFolder: (name, parentId, keyId) ->
      console.info "createFolder", name, parentId
      assert.defined name,     "name",     "createFolder"
      assert.defined parentId, "parentId", "createFolder"
      this._createFile(name, [], TYPE_FOLDER, parentId, keyId)

    createRootFolder: (masterKeyId) ->
      console.info "createRootFolder", masterKeyId
      assert.defined masterKeyId, "masterKeyId", "createRootFolder"
      new File({content: [], keyId: masterKeyId}).save()
      .then (root) =>
        console.log "root", root
        this.createFile("README", "Welcome", root._id, masterKeyId)
        return root._id

    getCurrentDirId: ->
      if $stateParams.path? and
      $stateParamas.path != ''
        return $stateParams.path
      else
        return session.getRootFolderId()

    instance: {
      history:  []
      current:  -1
      watchers: []

      goForward: (to) ->
        console.log "goForward", to
        assert.defined this.current, "this.current", "goForward"
        assert.defined this.history, "this.history", "goForward"
        assert.custom(
          this.current < this.history.length
          "<goForward> this.current >= this.history.length"
        )
        if this.current + 1 >= this.history.length
          unless to?
            return

        folder = if to? then to else new File({_id: this.history[this.current + 1]})
        folder.listContent().then (list) =>
          assert.defined list, "list", "goForward"
          this.fileTree = list
          this.current += 1
          if to?
            delete this.history[this.current..]
            this.history[this.current] = to._id
          this.notifyWatchers()

      goBackward: ->
        console.log "goBackward"
        assert.defined this.current, "this.current", "goBackward"
        if this.current > -1
          this.current -= 1
          this.notifyWatchers()

      goToFolder: (folder) ->
        console.log "goToFolder", file
        assert.defined folder, "file", "goToFolder"
        assert.defined folder.isFolder, "folder.isFolder", "goToFolder"
        if folder.isFolder()
          assert.defined folder.id, "folder.id", "goToFolder"
          this.goForward(folder)

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

      getShares: () ->
        console.info "getShares", session
        publicKeyId = crypto.getKeyIdFromKey(session.getMainPublicKey())
        console.log publicKeyId
        @shares = []
        storage.query 'proto/getShares', {key: publicKeyId}
        .then (list) =>
          @shares = new File(
            _id: "shares"
            metadata:
              name: 'Partages'
              type: 0
            content: []
          )
          for shareDoc in list
            clearShareDoc = crypto.asymDecrypt(
              session.getMainPrivateKey()
              shareDoc
            )
            console.log clearShareDoc
            keyId = session.registerKey(clearShareDoc.key)
            @shares.content.push {
              _id: clearShareDoc.docId
              keyId: keyId
            }
            @fileTree.push @shares
            console.log @fileTree[-1..][0]


      getFileContent: (id) ->
        new File({_id: id}).getContent()

      addFile: (metadata, content) ->
        _funcName = 'addFile'
        console.info _funcName, metadata
        assert.defined metadata.name, "metadata.name", _funcName
        assert.defined content, "content", _funcName
        metadata.name = @uniqueName(metadata.name)
        console.log "type", metadata.type
        tmpFile = {
          metadata: {
            name: metadata.name
            size: metadata.size
          }
        }
        if metadata.type == "" or metadata.type == TYPE_FOLDER
          tmpFile.metadata.type = TYPE_FOLDER
        else
          tmpFile.metadata.type = TYPE_FILE
        tmpFile = new File(tmpFile)
        tmpFile.uploading = true
        length = @fileTree.push tmpFile
        console.log length, @fileTree
        (if tmpFile.metadata.type == TYPE_FOLDER
          fm.createFolder(metadata.name, this.currentId())
        else
          fm.createFile(metadata.name, content, this.currentId())
        ).then (file) =>
          @fileTree[length-1] = file

      uniqueName: (name, parentDirContent) ->
        console.info "uniqueName", name
        unless parentDirContent
          parentDirContent = @fileTree
        assert.defined parentDirContent, "parentDirContent", "createFolder"
        assert.array   parentDirContent, "parentDirContent", "createFolder"
        s = name.split('.')
        basename  = s[0]
        extension = '.' + s[1..].join('.')
        i = 0
        while name in (f.metadata.name for f in parentDirContent)
          i += 1
          name = basename + " (" + i + ")" + extension
        console.info "new name", name
        return name

      createFile: ->
        console.info "createFile", this
        name = @uniqueName("new document")
        fm.createFile(name, "", this.currentId())
        .then (file) =>
          this.fileTree.push file

      createFolder: ->
        console.info "createFolder"
        name = @uniqueName("new folder")
        fm.createFolder(name, @currentId())
        .then (folder) =>
          @fileTree.push folder

      moveFile: (file, newParentId) ->
        _funcName = 'moveFile'
        console.info _funcName, file.metadata.parentId, newParentId
        assert.defined newParentId,   "newParentId",   _funcName
        assert.defined file.metadata.parentId, "file.parentId", _funcName
        @removeFileFromParentFolder().then =>
          new File({_id: newParentId}).listContent().then (content) =>
            file.metadata.name = uniqueName(file.metadata.name, content)
            file.addToFolder(newParentId). then(
              =>
                @metadata.parentId = newParentId
                @saveMetadata().then =>
                  if newParentId == fm.getCurrentDirId()
                    @fileTree.push file
              (err) =>
                # roll back
                console.error("move roll back")
                file.addToFolder(@metadata.parentId)
            )

      openFile: (file) ->
        console.info "openFile", file.name
        string2ArrayBuffer = (str) ->
          buf = new ArrayBuffer(str.length)
          bufView = new Uint8Array(buf)
          for i in [0..str.length-1]
            bufView[i] = str.charCodeAt(i)
          return buf

        file.getContent().then (content) =>
          console.log "content", content
          switch file.metadata.name.split('.')[-1..][0].toLowerCase()
            when "pdf" then type = "application/pdf"
            when "jpg" then type = "image/jpeg"
            when "png" then type = "image/png"
            when "mp3" then type = "audio/mpeg"
            else type = "text/plain"
          blob = new Blob([string2ArrayBuffer(content)], {type: type})
          url = URL.createObjectURL(blob)
          link = document.createElement('a')
          link.href = url
          link.download = file.metadata.name
          e = document.createEvent('MouseEvents')
          e.initEvent('click' ,true ,true)
          link.dispatchEvent(e)

      removeFileFromParentFolder: (file) ->
        _funcName = "removeFileFromFolder"
        console.info _funcName
        assert.defined file._id, "file._id", _funcName
        assert.defined file.metadata.parentId, "file.metadata.parentId", _funcName
        File.getFile(file.metadata.parentId).then (folder) =>
          assert.array folder.content, "folder.content", _funcName
          folder.content.splice(
            folder.content.indexOf(file._id)
            1)
          folder.saveContent().then =>
            #TODO: change @ to a triggered update via changes watcher
            cache.expire(folder._id, "content")
            folder.listContent()

      deleteFile: (file) ->
        _funcName = "deleteFile"
        console.info _funcName
        @removeFileFromParentFolder(file).then =>
          if file.isFolder()
            file.listContent().then (list) =>
              for f in list
                f.remove()
          file.remove()
          @fileTree.splice(
            @fileTree.indexOf(file)
            1)
          #for i, f of @fileTree
          #  if f.metadata.name == file.metadata.name
          #    delete @fileTree[i]
    }

    getInstance: (path) ->
      _funcName = "getInstance"
      console.info _funcName, path, (if $scopeVar? then "$scope." + scopeVar)
      if path?
        if path is "" or path is "/"
          folderId = session.getRootFolderId()
        else
          folderId = path
        assert.defined folderId, "folderId", _funcName
        console.log "shares", this.instance.shares
        console.log "folderId", folderId
        folder = if folderId == "shares" then this.instance.shares else new File({_id: folderId})
        this.instance.goForward(folder).finally(
          =>
            console.log "moved to folderId", folderId
            unless this.instance.shares
              this.instance.getShares()
          (err) =>
            console.error(err)
        )
      return this.instance
  }
)
