angular.module('fileManager').
factory 'Folder', ($q, crypto, FileSystemNode, CrypTree) ->
  class Folder extends FileSystemNode
    constructor: (doc, parentKey, parentId) ->
      console.log "new Folder"
      super(doc, parentKey, parentId)

    #
    # class methods
    #
    @_getDataKeyLinkKey: (doc, parentFolder) ->
      console.log "Folder._getDataKeyLinkKey"
      super.then (parentFolderKey) =>
        if not doc.isFolder
          return parentFolderKey
        console.debug "get sfk", doc.subfolderKeyLink, parentFolderKey
        CrypTree.resolveSymLink doc.subfolderKeyLink, parentFolderKey
        .then (subfolderKey) =>
          doc.subfolderKey = subfolderKey
          return subfolderKey

    @getFileOrFolder: (id, linkOrKey, parentFolder) ->
      @get(id, linkOrKey, parentFolder).then (folder) =>
        if not folder.isFolder()
          file = new File(folder)
          file.parentId = folder.parentId
          return file
        return folder

    generateReadCrypTreeKeys: (parentKey) ->
      console.log "Folder.generateReadCrypTreeKeys"
      @subfolderKey = crypto.generateSymKey()
      @filesKey = crypto.generateSymKey()
      @dataKey = crypto.generateSymKey()
      CrypTree.symLink(parentKey, @subfolderKey).then (subfolderKeyLink) =>
        @subfolderKeyLink = subfolderKeyLink
      CrypTree.symLink(@subfolderKey, @filesKey).then (filesKeyLink) =>
        @filesKeyLink = filesKeyLink
      CrypTree.symLink(@subfolderKey, @dataKey).then (dataKeyLink) =>
        @dataKeyLink = dataKeyLink

    generateWriteCrypTreeKeys: () ->

    _createMetadataDoc: () ->
      {
        _id:              @_id
        _rev:             @_rev
        data:             @metadata
        dataKeyLink:      @dataKeyLink
        subfolderKeyLink: @subfolderKeyLink
        filesKeyLink:     @filesKeyLink
        keyDurty:         @keyDurty
        isFolder:         true
        parentId:          @parentId
      }

    getFilesKey: () ->
      if not @filesKey?
        CrypTree.resolveSymLink @filesKeyLink, @subfolderKey
      else
        $q.when(@filesKey)

    addSubFolder: (folder) ->
      console.log "addSubFolder", folder
      @getContent().then =>
        CrypTree.symLink(@subfolderKey, folder.subfolderKey).then (link) =>
          @content.push {
            id: folder._id
            link: link
          }
          @saveContent().then =>
            folder.parentId = @_id
            folder.saveMetadata()

    addFile: (file) ->
      console.log "addFile", file
      if file.isFolder()
        return @addSubFolder(file)
      @getContent().then =>
        @getFilesKey().then (filesKey) =>
          CrypTree.symLink(filesKey, file.dataKey).then (link) =>
            @content.push {
              id: file._id
              link: link
            }
            @saveContent().then =>
              file.parentId = @_id
              file.saveMetadata()

    indexOfSubFolder: (folder) ->
      for i, f of @content
        if f._id == folder._id
          return i
      return -1

    removeSubFolder: (folder) ->
      i = @indexOfSubFolder(folder)
      if i >= 0
        @content.splice i, 1
        @saveContent()

    removeFile: (file) ->
      @removeSubFolder()

  window.Folder = Folder