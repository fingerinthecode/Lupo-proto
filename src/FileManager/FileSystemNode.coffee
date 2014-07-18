angular.module('fileManager').
factory 'FileSystemNode', ($q, assert, crypto, DbDoc, CrypTree, session) ->
  class FileSystemNode
    constructor: (doc, parentKey, parentId) ->
      console.log "new File/Folder", doc, parentKey
      @_id              = doc._id
      @_rev             = doc._rev
      @metadata         = doc.metadata || doc.data || {}
      @content          = doc.content

      @dataKeyLink      = doc.dataKeyLink
      @subfolderKeyLink = doc.subfolderKeyLink
      @filesKeyLink     = doc.filesKeyLink

      @subfolderKey     = doc.subfolderKey
      @dataKey          = doc.dataKey

      @parentId         = doc.parentId or parentId
      @keyDurty         = if doc.keyDurty? then doc.keyDurty else false

      if not @dataKey and parentKey?
        @generateReadCrypTreeKeys(parentKey)
        @generateWriteCrypTreeKeys()

    #
    # Class methods
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
      #if not parentFolder?
      #  key = session.getMasterKey()
      #  console.debug "session.getMasterKey():", key
      #  if not key
      #    key = session.getFlash 'masterKey'
      #    console.debug "session.getFlash:", key
      #  $q.when(key)
      #else
      if doc.isFolder
        $q.when(parentFolder.subfolderKey)
      else
        parentFolder.getFilesKey()

    @_getDataKeyLinkKey: (doc, parentFolder) ->
      @_getParent(doc, parentFolder)
      .then (parentFolder) =>
        console.log "parentFolder", parentFolder
        @_getParentKey(doc, parentFolder)
      .catch () =>
        throw "Impossible to open this file/folder"

    @_getDataKey: (doc, parentFolder) ->
      @_getDataKeyLinkKey(doc, parentFolder).then (key) =>
        console.log "parentKey", key
        CrypTree.resolveSymLink doc.dataKeyLink, key

    # 4 access types:
    # - standard:              File.get id, link, parentFolder
    # - no parentFolder known: File.get id
    # - shares:                File.get id, dataKey
    # - rootFolder:            File.get id, undefined, {subfolderKey: masterKey}
    # TODO: clarify/simplify this!
    @get: (id, linkOrKey, parentFolder) ->
      _funcName = "File.get"
      console.log _funcName, id
      assert.defined id, "id", _funcName
      DbDoc.get(id).then (doc) =>
        if not crypto.isEncrypted(doc)
          new @(doc)
        else
          # find file dataKey
          (if linkOrKey?
            if not parentFolder?
              $q.when linkOrKey
            else
              @_getParentKey(doc, parentFolder).then (parentKey) =>
                CrypTree.resolveSymLink(linkOrKey, parentKey).then (key) =>
                  console.log "dataOrSFKey", key
                  if not doc.isFolder
                    return key
                  else
                    return CrypTree.resolveSymLink(doc.dataKeyLink, key)
          else
            @_getDataKey(doc, parentFolder)
          ).then (dataKey) =>
            console.log "dataKey", dataKey
            try
              DbDoc.decryptDataField(doc, dataKey).then (doc) =>
                doc.dataKey = dataKey
                new @(doc)
            catch
              console.error "decrypt error"


    @getMetadata: (id, parentKey) ->
      @get(id, parentKey)

    generateReadCrypTreeKeys: (parentKey) ->

    generateWriteCrypTreeKeys: (parentKey) ->

    isFolder: () ->
      return @subfolderKeyLink?
      #if @content?
      #  return assert.tests.isAnArray(@content)

    getContent: (parentKey) ->
      console.log "getContent", @_id
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
      console.log _funcName

      DbDoc.encryptAndSave(@_createMetadataDoc(), @dataKey).then (result) =>
        @_id = result.id
        @_rev = result.rev
        return @

    saveContent: () ->
      _funcName = "saveContent"
      console.log _funcName
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
      console.debug "saveContent", content, @dataKey
      DbDoc.encryptAndSave(content, @dataKey)

    save: () ->
      _funcName = "save"
      console.log _funcName
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
      console.log _funcName
      if @metadata.contentId?
        DbDoc.delete {_id: @metadata.contentId}, @dataKey
      DbDoc.delete {_id: @_id}, @dataKey