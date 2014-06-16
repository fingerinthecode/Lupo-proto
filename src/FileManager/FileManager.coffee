angular.module('fileManager').
factory('fileManager', ($q, $stateParams, $state, assert, crypto, session, storage, cache, File, usSpinnerService, $filter, notification) ->
  TYPE_FOLDER = 0
  TYPE_FILE = 1
  {
    updatePath: ->
      _funcName = "updatePath"
      console.info _funcName, $stateParams.path
      usSpinnerService.spin('main')
      folderId = @getCurrentDirId()
      assert.defined folderId, "folderId", _funcName
      console.log "folderId", folderId
      folder = new File({_id: folderId})
      @getSharesFolderIfNeeded(folder).then =>
        console.debug "shares", @shares
        if folder._id == "shares"
          if @shares.content.length == 0
            $state.go(".", session.getRootFolderId())
          else
            folder = @shares
        @goToFolder(folder).then(
          =>
            console.log "moved to folderId", folderId
            if @isRootFolder(folder)
              @getShares().then =>
                if not @fileTree.length or
                @shares.content.length > 0 and
                @fileTree[0]._id != "shares"
                  @fileTree.unshift @shares
            usSpinnerService.stop('main')

          (err) =>
            usSpinnerService.stop('main')
            notification.addAlert("Not authorized")
            $state.go('.', {path: ""}, {location: 'replace'})
        )
      return @

    getSharesFolderIfNeeded: (folder) ->
      if folder._id == "shares"
        @getShares()
      else
        $q.when()

    isRootFolder: (folder) ->
      console.error "isRootFolder", folder._id, session.getRootFolderId()
      return folder._id == session.getRootFolderId()

    goToFolder: (folder) ->
      _funcName = "goToFolder"
      console.log _funcName, folder
      assert.defined folder, "folder", _funcName
      folder.listContent().then (list) =>
        @fileTree = list

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
            name: $filter('translate')('Shares')
            type: 0
          content: []
        )
        diffList = []
        for _id in list
          diffList.push storage.get(_id).then (shareDoc) =>
            crypto.asymDecrypt(
              session.getMainPrivateKey()
              shareDoc.data
            ).then (clearData) =>
              keyId = session.registerKey(clearData.key)
              @shares.content.push {
                _id: clearData.docId
                keyId: keyId
              }
              console.debug "shares", @shares
            .catch (err) =>
              console.error "asymDecrypt error"
        return $q.all(diffList)


    getFileContent: (id) ->
      new File({_id: id}).getContent()

    addFile: (metadata, content) ->
      _funcName = 'addFile'
      console.info _funcName, metadata
      assert.defined metadata.name, "metadata.name", _funcName
      assert.defined content, "content", _funcName

      (if metadata.type == TYPE_FOLDER
        @createFolder(metadata, @getCurrentDirId())
      else
        @createFile(metadata, content, @getCurrentDirId())
      ).then (file) =>
        for i, f of @fileTree
          if f.metadata.name == file.metadata.name
            @fileTree[i] = file
            break

    uniqueName: (name, parentDirContent) ->
      console.info "uniqueName", name
      unless parentDirContent
        parentDirContent = @fileTree
      assert.defined parentDirContent, "parentDirContent", "uniqueName"
      assert.array   parentDirContent, "parentDirContent", "uniqueName"
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
      name = @uniqueName($filter('translate')("new document"))
      @createFile({name: name}, "", @getCurrentDirId())
      .then (file) =>
        this.fileTree.push file

    newFolder: ->
      console.info "createFolder"
      name = @uniqueName($filter('translate')("new folder"))
      @createFolder({name: name}, @getCurrentDirId())
      .then (folder) =>
        @fileTree.push folder

    _createFile: (metadata, content, parentId, keyId) ->
      _funcName = "_createFile"
      console.info _funcName, metadata, content, parentId
      assert.defined metadata, "metadata", _funcName
      assert.defined content,  "content",  _funcName
      assert.defined parentId, "parentId", _funcName
      new File({_id: parentId, keyId: keyId}).listContent().then(
        (list) =>
          console.log "list", list
          assert.defined list, "list", _funcName
          unless metadata.name in [f.metadata.name for f in list]
            content = if content? then content else ""
            if metadata.type != TYPE_FOLDER
              metadata.size = metadata.size || content.length
            newFile = new File {
              content: content
              metadata: metadata
              keyId: keyId
            }
            newFile.save()
            .then (result) =>
              newFile.addToFolder(parentId, keyId)

        (err) =>
          return "parent does not exist"
      )

    createFile: (metadata, content, parentId, keyId) ->
      _funcName = "createFile"
      console.info _funcName, metadata, content, parentId
      assert.defined metadata, "metadata", _funcName
      assert.defined content,  "content",  _funcName
      assert.defined parentId, "parentId", _funcName
      metadata.type = TYPE_FILE
      this._createFile(metadata, content, parentId, keyId)

    createFolder: (metadata, parentId, keyId) ->
      console.info "createFolder", metadata, parentId
      assert.defined metadata, "metadata", "createFolder"
      assert.defined parentId, "parentId", "createFolder"
      metadata.type = TYPE_FOLDER
      this._createFile(metadata, [], parentId, keyId)

    createRootFolder: (masterKeyId) ->
      console.info "createRootFolder", masterKeyId
      assert.defined masterKeyId, "masterKeyId", "createRootFolder"
      new File({content: [], keyId: masterKeyId}).save()
      .then (root) =>
        console.log "root", root
        this.createFile(
          {name: $filter('translate')("README")}
          $filter('translate')("Welcome")
          root._id
          masterKeyId
        )
        .then =>
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
      usSpinnerService.spin('main')
      (if file.isFolder()
        @openFolder(file)
      else
        @openFile(file)
      ).then(
        =>
          usSpinnerService.stop('main')
        =>
          usSpinnerService.stop('main')
          notification.addAlert("Not authorized")
          $state.go('.')
          notification.addAlert("Not authorized")
      )

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
