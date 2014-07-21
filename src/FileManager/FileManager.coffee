angular.module('fileManager').
factory('fileManager', ($q, $stateParams, $state, assert, crypto, session, storage, cache, File, Folder, usSpinnerService, $filter, Notification, $rootScope, DeferredQueue) ->
  fileManager = {
    fileTree: []
    lightTaskQueue: new DeferredQueue(5)
    heavyTaskQueue: new DeferredQueue(1)

    updatePath: ->
      _funcName = "updatePath"
      console.info _funcName, $stateParams.path
      usSpinnerService.spin('main')
      folderId = @getCurrentDirId()
      console.log "folderId", folderId
      @getSharesFolderIfNeeded(folderId).then =>
        console.debug "shares", @shares
        (if folderId == "shares"
          if @shares.content.length == 0
            $state.go(".", session.getRootFolderId())
          else
            $q.when @shares
        else
          if @isRootFolder(folderId)
            parentFolder = {subfolderKey: session.getMasterKey()}
          #FIXME: have the parentFolder in most cases
          Folder.get folderId, undefined, parentFolder
        ).then (folder) =>
          @goToFolder(folder).then =>
            console.log "moved to folder._id", folder._id
            if @isRootFolder(folder)
              @getShares().then =>
                if not @fileTree.length or
                @shares.content.length > 0 and
                @fileTree[0]._id != "shares"
                  @fileTree.unshift @shares
            usSpinnerService.stop('main')

          .catch (err) =>
            usSpinnerService.stop('main')
            Notification.addAlert("Not authorized")
            $state.go('.', {path: ""}, {location: 'replace'})
      return @

    getSharesFolderIfNeeded: (folderId) ->
      if folderId == "shares"
        @getShares()
      else
        $q.when()

    isRootFolder: (idOrFolder) ->
      if angular.isString idOrFolder
        return idOrFolder == session.getRootFolderId()
      if angular.isObject idOrFolder
        return idOrFolder._id == session.getRootFolderId()

    goToFolder: (folder) ->
      _funcName = "goToFolder"
      console.log _funcName, folder
      assert.defined folder, "folder", _funcName
      @listFolderContent(folder).then (list) =>
        @fileTree = list

    getCurrentDirId: ->
      if $stateParams.path? and
      $stateParams.path != ''
        return $stateParams.path
      else
        return session.getRootFolderId()

    getCurrentFolder: ->
      Folder.get(@getCurrentDirId())

    getShares: () ->
      console.info "getShares", session
      publicKeyId = crypto.getKeyIdFromKey(session.getMainPublicKey())
      console.log publicKeyId
      storage.query 'proto/getShares', {key: publicKeyId}
      .then (list) =>
        @shares = new Folder(
          _id: "shares"
          subfolderKeyLink: "fake"
          metadata:
            name: $filter('translate')('Shares')
          content: []
        )
        diffList = []
        for _id in list
          diffList.push storage.get(_id).then (shareDoc) =>
            crypto.asymDecrypt(
              session.getMainPrivateKey()
              shareDoc.data
            ).then (clearData) =>
              #keyId = session.registerKey(clearData.key)
              @shares.content.push {
                id:  clearData.docId
                key: clearData.key
              }
              console.debug "shares", @shares
            .catch (err) =>
              console.error "asymDecrypt error"
        return $q.all(diffList)

    addFile: (metadata, content) ->
      _funcName = 'addFile'
      console.info _funcName, metadata
      assert.defined metadata.name, "metadata.name", _funcName
      assert.defined content, "content", _funcName
      @getCurrentFolder().then (parentFolder) =>
        (if metadata.type == File.TYPES.FOLDER
          @createFolder(metadata, parentFolder)
        else
          @createFile(metadata, content, parentFolder)
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
      extension = s[1..].join('.')
      i = 0
      while name in (f.metadata.name for f in parentDirContent)
        i += 1
        name = basename + " (" + i + ")"
        if extension.length
          name += '.' + extension
      console.info "new name", name
      return name

    newFile: ->
      name = @uniqueName($filter('translate')("new document"))
      @getCurrentFolder().then (parentFolder) =>
        @createFile({name: name, type: "plain/text"}, "", parentFolder)
        .then (file) =>
          this.fileTree.push file

    newFolder: ->
      name = @uniqueName($filter('translate')("new folder"))
      @getCurrentFolder().then (parentFolder) =>
        @createFolder({name: name}, parentFolder)
        .then (folder) =>
          @fileTree.push folder

    isFileNameUnique : (name, parentFolder) ->
      parentFolder.getContent
      @listFolderContent(parentFolder).then (list) =>
        if name in [f.metadata.name for f in list]
          #FIXME: handle same name case
          deferred = $q.defer()
          deferred.reject()
          return deferred

    createFile: (metadata, content, parentFolder) ->
      _funcName = "createFile"
      console.info _funcName, metadata, parentFolder
      assert.defined metadata, "metadata", _funcName
      assert.defined content,  "content",  _funcName
      assert.defined parentFolder, "parentFolder", _funcName
      metadata.size = metadata.size || content.length
      parentFolder.getFilesKey().then (filesKey) =>
        @isFileNameUnique(metadata.name, parentFolder).then =>
          newFile = new File({
              content: content or ""
              metadata: metadata
            }
            filesKey
          )
          newFile.save()
          .then =>
            parentFolder.addFile(newFile)

    createFolder: (metadata, parentFolder) ->
      console.info "createFolder", metadata, parentFolder
      assert.defined metadata, "metadata", "createFolder"
      assert.defined parentFolder, "parentFolder", "createFolder"
      @isFileNameUnique(metadata.name, parentFolder).then =>
        newFolder = new Folder({
            content: []
            metadata: metadata
          }
          parentFolder.subfolderKey
        )
        newFolder.save()
        .then =>
          parentFolder.addSubFolder(newFolder)

    createRootFolder: (masterKey) ->
      console.info "createRootFolder", masterKey
      assert.defined masterKey, "masterKey", "createRootFolder"
      new Folder({content: []}, masterKey).save()
      .then (root) =>
        console.log "root", root
        this.createFile(
          {name: $filter('translate')("README")}
          $filter('translate')("README_CONTENT")
          root
        )
        .then =>
          return root._id

    listFolderContent: (idOrFolder) ->
      _funcName = "listFolderContent"
      console.log _funcName, idOrFolder
      assert.defined idOrFolder, "idOrFolder", _funcName
      deferred = $q.defer()
      inProgess = 0
      (if angular.isObject(idOrFolder)
        $q.when(idOrFolder)
      else
        Folder.get(idOrFolder)
      ).then (folder) =>
        folder.getContent().then (content) =>
          assert.array content, "content", _funcName
          list = []
          atLeastOne = false
          for element in content
            if element?
              atLeastOne = true
              inProgess +=1

              (if element.key
                Folder.getFileOrFolder(element.id, element.key)
              else
                Folder.getFileOrFolder(element.id, element.link, folder)
              ).then(
                (file) =>
                  if file.isFolder()
                    file.content = []
                    if element.link
                      file.subfolderKeyLink = element.link
                  else
                    file.dataKeyLink = element.link
                  list.push(file)
                  inProgess -= 1
                (err) =>
                  inProgess -= 1
              )
              .then =>
                if inProgess == 0
                  # if all deferred are terminated #
                  console.debug "list", list
                  deferred.resolve(list)
          unless atLeastOne
            deferred.resolve([])
      .catch (err) =>
        deferred.reject(err)
      return deferred.promise

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
          Notification.addAlert("Not authorized")
          $state.go('.')
          Notification.addAlert("Not authorized")
      )

    openFolder: (folder) ->
      console.info "openFolder", folder
      if folder.isFolder()
        $state.go('.', {
          path: folder._id
        }, {
          location: true
        })

    getMimeType: (file) ->
      if angular.isString file.metadata.type
        return file.metadata.type
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
        try
          type = content.split(',')[0].split(':')[1].split(';')[0]
          byteString = atob(content.split(',')[1])
        catch
          type = @getMimeType(file)
          byteString = content
        blob = new Blob([string2ArrayBuffer(byteString)], {type: type})
        return URL.createObjectURL(blob)

    openFile: (file) ->
      console.info "openFile"
      @buildFileUrl(file).then (url) =>
        link = document.createElement('a')
        link.href = url
        link.download = file.metadata.name
        e = document.createEvent('MouseEvents')
        e.initEvent('click', true, true)
        link.dispatchEvent(e)

    removeFileFromFolder: (file, parentFolder) ->
      _funcName = "removeFileFromFolder"
      console.info _funcName
      assert.defined file._id, "file._id", _funcName
      Folder.get(parentFolder).then (folder) =>
        assert.array folder.content, "folder.content", _funcName
        if folder._id == @getCurrentDirId()
          for i, f of @fileTree
            if f._id == file._id
              @fileTree.splice(i, 1)
              break
        folder.content.splice(
          folder.content.indexOf(file._id)
          1)
        folder.saveContent().then =>
          #TODO: change @ to a triggered update via changes watcher
          cache.expire(folder._id, "content")
          @listFolderContent(folder._id)
        .catch (err) =>
          if err.status == 409
            cache.expire(folder._id, "content")
            @removeFileFromFolder(file, parentFolder)

    deleteFile: (file) ->
      _funcName = "deleteFile"
      console.info _funcName
      file.loading = true
      @heavyTaskQueue.enqueue =>
        @getCurrentFolder().then (currentFolder) =>
          @removeFileFromFolder(file, currentFolder).then =>
            if file.isFolder()
              # FIXME: could be parallized
              @listFolderContent(file).then (list) =>
                for f in list
                  f.remove()
            file.remove()

    moveFile: (file, newParent) ->
      _funcName = 'moveFile'
      assert.defined file, "file", _funcName
      assert.defined newParent,   "newParent",  _funcName
      @getCurrentFolder().then (currentFolder) =>
        @removeFileFromFolder(file, currentFolder).then =>
          @listFolderContent(newParent).then (content) =>
            file.metadata.name = @uniqueName(file.metadata.name, content)
            Folder.get(newParentId).then (newParent) =>
              newParent.addFile(file).then(
                =>
                  if newParentId == @getCurrentDirId()
                    @fileTree.push file
                (err) =>
                  # roll back
                  console.error("move roll back")
                  Folder.get(@metadata.parentId).then (parentFolder) =>
                    parentFolder.addFile(file)
              )

    renameFile: (file, newName) ->
      _funcName = 'renameFile'
      console.log _funcName, newName
      assert.defined newName, "newName", _funcName
      file.metadata.name = newName
      file.saveMetadata()

    shareFile: (file, user) ->
      _funcName = "shareFile"
      console.log _funcName, user
      assert.defined user, "user", _funcName
      #TMP: later share would have a "user" parameter
      console.log "user", user
      shareDoc = {
        "_id": crypto.hash(user._id + file._id, 32)
        "data": {
          "docId": file._id
          "key":   file.dataKey
        }
        "userId": user._id
      }
      crypto.asymEncrypt user.publicKey, shareDoc.data
      .then (encData) =>
        shareDoc.data = encData
        storage.save(shareDoc).then =>
          unless file.metadata.sharedWith
            file.metadata.sharedWith = []
          file.metadata.sharedWith.push user.name
          file.saveMetadata()


  }

  $rootScope.$on('$stateChangeSuccess', ($event, toState)->
    if toState.name == 'explorer.files' and session.isConnected()
      fileManager.updatePath()
  )

  return fileManager
)
