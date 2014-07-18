angular.module('fileManager').
factory 'File', (FileSystemNode, Folder, crypto, CrypTree) ->
  class File extends FileSystemNode
    #FIXME: to be removed
    @TYPES:
      FOLDER: 0
      FILE:   1


    generateReadCrypTreeKeys: (parentKey) ->
      @dataKey = crypto.generateSymKey()
      CrypTree.symLink(parentKey, @dataKey).then (dataKeyLink) =>
        @dataKeyLink = dataKeyLink

    _createMetadataDoc: () ->
      {
        _id:         @_id
        _rev:        @_rev
        data:        @metadata
        dataKeyLink: @dataKeyLink
        keyDurty:    @keyDurty
        isFolder:    false
        parentId:     @parentId
      }

  window.File = File