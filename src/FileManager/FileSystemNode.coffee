angular.module('fileManager').
factory 'FileSystemNode', ($q, assert, crypto, DbDoc, CrypTree, session, $log) ->
  class FileSystemNode
    constructor: (doc, parentKey, parentId = null) ->
      $log.log "new File/Folder", doc, parentKey
      @_id              = doc._id
      @_rev             = doc._rev
      @metadata         = doc.metadata ? doc.data ? {}
      @content          = doc.content

      @dataKeyLink      = doc.dataKeyLink
      @subfolderKeyLink = doc.subfolderKeyLink
      @filesKeyLink     = doc.filesKeyLink

      @subfolderKey     = doc.subfolderKey
      @dataKey          = doc.dataKey

      @parentId         = parentId ? doc.parentId
      @keyDurty         = doc.keyDurty ? false

      if not @dataKey and parentKey?
        @generateReadCrypTreeKeys(parentKey)
        @generateWriteCrypTreeKeys()

    #
    # Static method
    #
    @_getParent: (doc, parentFolder) ->
      deferred = $q.defer()
      if parentFolder?
        deferred.resolve(parentFolder)
      else
        if not doc.parentId?
          deferred.reject()
        else
          return Folder.get(doc.parentId)
      return deferred.promise

    @_getParentKey: (doc, parentFolder) ->
      if doc.isFolder
        $q.when(parentFolder.subfolderKey)
      else
        parentFolder.getFilesKey()

    @_getDataKeyLinkKey: (doc, parentFolder) ->
      @_getParent(doc, parentFolder)
      .then (parentFolder) =>
        $log.log "parentFolder", parentFolder
        @_getParentKey(doc, parentFolder)
      .catch () =>
        throw "Impossible to open this file/folder"

    @_getKeys: (doc, parentFolder) ->
      @_getDataKeyLinkKey(doc, parentFolder).then (key) =>
        $log.log "parentKey", key
        CrypTree.resolveSymLink(doc.dataKeyLink, key).then (dataKey) =>
          return [dataKey, key]

    # 4 access types:
    # - standard:              File.get id, link, parentFolder
    # - no parentFolder known: File.get id
    # - shares:                File.get id, dataKey
    # - rootFolder:            File.get id, undefined, {subfolderKey: masterKey}
    # TODO: clarify/simplify this!
    @get: (id, linkOrKey, parentFolder) ->
      _funcName = "File.get"
      $log.log _funcName, id
      assert.defined id, "id", _funcName
      DbDoc.get(id).then (doc) =>
        if not crypto.isEncrypted(doc)
          return new @(doc)

        # find file dataKey and maybe subfolderKey also
        (if linkOrKey?
          if not parentFolder?
            $q.when linkOrKey
          else
            @_getParentKey(doc, parentFolder).then (parentKey) =>
              CrypTree.resolveSymLink(linkOrKey, parentKey).then (key) =>
                $log.log "dataOrSFKey", key
                if not doc.isFolder
                  # dataKey
                  return key
                else
                  # subfolderKey
                  return CrypTree.resolveSymLink(doc.dataKeyLink, key).then (dataKey) =>
                    return [dataKey, key]
        else
          @_getKeys(doc, parentFolder)
        ).then (keys) =>
          if not angular.isArray(keys)
            keys = [keys]
          $log.log "keys", keys
          dataKey = keys[0]
          if keys.length > 1
            subfolderKey = keys[1]
          try
            DbDoc.decryptDataField(doc, dataKey).then (doc) =>
              doc.dataKey = dataKey
              doc.subfolderKey = subfolderKey
              new @(doc)
          catch
            $log.error "decrypt error"

    @getMetadata: (id, parentKey) ->
      @get(id, parentKey)

    #
    # no-Static method
    #
    generateReadCrypTreeKeys: (parentKey) ->

    generateWriteCrypTreeKeys: (parentKey) ->

    isFolder: () ->
      return @subfolderKeyLink?
      #if @content?
      #  return assert.tests.isAnArray(@content)

    getContent: (parentKey) ->
      $log.log "getContent", @_id
      assert.defined @_id, "@_id", "getContent"
      if @_id == "shares"
        return $q.when(@content)
      if @content?
        $q.when(@content)
      if @metadata?
        DbDoc.getAndDecrypt(@metadata.contentId, @dataKey).then (doc) =>
          @content = doc.data.content
          @metadataDocList = doc.data.metadataDocList
          @contentRev = doc._rev
          return @content
      else
        @constructor.get(@_id, @dataKeyLink, parentKey).then (file) =>
          file.getContent().then (content) =>
            return content

    _createMetadataDoc: () ->


    saveMetadata: () ->
      _funcName = "saveMetadata"
      $log.log _funcName

      DbDoc.encryptAndSave(@_createMetadataDoc(), @dataKey).then (result) =>
        @_id = result.id
        @_rev = result.rev
        return @

    saveContent: () ->
      _funcName = "saveContent"
      $log.log _funcName
      content = {
        data: {
          content: @content
        }
      }
      if @metadataDocList?
        content.data.metadataDocList = @metadataDocList
      if @metadata?
        if @metadata.contentId?
          content._id = @metadata.contentId
        if @contentRev?
          content._rev = @contentRev
      else
        if @_id
          content._id = @_id
        if @_rev
          content._rev = @_rev
      $log.debug "saveContent", content, @dataKey
      DbDoc.encryptAndSave(content, @dataKey)

    save: () ->
      _funcName = "save"
      $log.log _funcName
      if @content?
        @saveContent().then (contentResult) =>
          unless @metadata?
            @_id = contentResult.id
            @_rev = contentResult.rev
            return @
          assert.unchanged(contentResult.id, @metadata.contentId,
            "contentResult.id", "@metadata.contentId", _funcName)
          @metadata.contentId = contentResult.id
          @saveMetadata()
      else
        if @metadata?
          @saveMetadata().then =>
            return @

    delete: ->
      _funcName = 'delete'
      $log.log _funcName
      if @metadata.contentId?
        DbDoc.delete {_id: @metadata.contentId}, @dataKey
      DbDoc.delete @, @dataKey
