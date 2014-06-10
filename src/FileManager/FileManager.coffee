angular.module('fileManager').
factory('fileManager', ($q, $stateParams, $state, assert, crypto, session, storage, cache, File) ->
  TYPE_FOLDER = 0
  TYPE_FILE = 1
  {
    updatePath: ->
      _funcName = "updatePath"
      console.info _funcName
      folderId = @getCurrentDirId()
      assert.defined folderId, "folderId", _funcName
      console.log "shares", @shares
      console.log "folderId", folderId
      if folderId == "shares"
        if not @shares?
          $state.go("/" + session.getRootFolderId())
        else
          folder = @shares
      else
        folder = new File({_id: folderId})
      @goToFolder(folder).finally(
        =>
          console.log "moved to folderId", folderId
          if isRootFolder(folder) and not @shares?
            @getShares()
        (err) =>
          console.error(err)
      )
      return @

    isRootFolder: (folder) ->
      return folder._id == session.getRootFolderId()

    goToFolder: (folder) ->
      _funcName = "goToFolder"
      console.log _funcName, folder
      assert.defined folder, "folder", _funcName
      folder.listContent().then (list) =>
        @fileTree = list
        if @shares? and @isRootFolder(folder)
          @fileTree.push @shares

    getCurrentDirId: ->
      if $stateParams.path? and
      $stateParams.path != ''
        return $stateParams.path
      else
        return session.getRootFolderId()

    getShares: () ->
      console.info "getShares", session
      publicKeyId = crypto.getKeyIdFromKey(session.getMainPublicKey())
      console.log publicKeyId
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
          keyId = session.registerKey(clearShareDoc.key)
          @shares.content.push {
            _id: clearShareDoc.docId
            keyId: keyId
          }


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
        @createFolder(metadata.name, @getCurrentDirId())
      else
        @createFile(metadata.name, content, @getCurrentDirId())
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

    newFile: ->
      console.info "createFile"
      name = @uniqueName("new document")
      @createFile(name, "", @getCurrentDirId())
      .then (file) =>
        this.fileTree.push file

    newFolder: ->
      console.info "createFolder"
      name = @uniqueName("new folder")
      @createFolder(name, @getCurrentDirId())
      .then (folder) =>
        @fileTree.push folder

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

    moveFile: (file, newParentId) ->
      _funcName = 'moveFile'
      assert.defined file, "file", _funcName
      console.info _funcName, file.metadata.parentId, newParentId
      assert.defined newParentId,   "newParentId",   _funcName
      assert.defined file.metadata.parentId, "file.metadata.parentId", _funcName
      @removeFileFromParentFolder(file).then =>
        new File({_id: newParentId}).listContent().then (content) =>
          file.metadata.name = @uniqueName(file.metadata.name, content)
          file.addToFolder(newParentId). then(
            =>
              file.metadata.parentId = newParentId
              file.saveMetadata().then =>
                if newParentId == @getCurrentDirId()
                  @fileTree.push file
            (err) =>
              # roll back
              console.error("move roll back")
              file.addToFolder(@metadata.parentId)
          )

    openFileOrFolder: (file) ->
      if file.isFolder()
        @openFolder(file)
      else
        @openFile(file)

    openFolder: (folder) ->
      console.info "openFolder",
      if folder.isFolder()
        $state.go('.', {
          path: folder._id
        }, {
          location: true
        })

    getMimeType: (file) ->
      switch file.metadata.name.split('.')[-1..][0].toLowerCase()
        when "pdf" then type = "application/pdf"
        when "jpg" then type = "image/jpeg"
        when "png" then type = "image/png"
        when "mp3" then type = "audio/mpeg"
        else type = "text/plain"
      return type

    buildFileUrl: (file) ->
      string2ArrayBuffer = (str) ->
        buf = new ArrayBuffer(str.length)
        bufView = new Uint8Array(buf)
        for i in [0..str.length-1]
          bufView[i] = str.charCodeAt(i)
        return buf

      file.getContent().then (content) =>
        console.log "content", content
        type = @getMimeType(file)
        blob = new Blob([string2ArrayBuffer(content)], {type: type})
        URL.createObjectURL(blob)

    openFile: (file) ->
      console.info "openFile"

      @buildFileUrl(file).then (url) =>
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
        if folder._id == @getCurrentDirId()
          @fileTree.splice(
            folder.content.indexOf(file._id)
            1)
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
  }
)
