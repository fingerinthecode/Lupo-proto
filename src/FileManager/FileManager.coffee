angular.module('fileManager').
factory('fileManager', (crypto, session, storage)->
  {
    _getFileOrFolder: (id, key) ->
      unless key?
        key = session.getMasterKey()
      assert(key?, "key is undefined")
      storage.get(id).then (doc) =>
        crypto.decryptDataField(key, doc)
        return doc

    _saveFileOrFolder: (doc, key) ->
      console.log doc, key
      unless key?
        key = session.getMasterKey()
      assert(key?, "key is undefined")
      crypto.encryptDataField(key, doc)
      storage.save(doc).then(
        (savedDoc) =>
          console.log "created", savedDoc
          return savedDoc.id
        (err) =>
          console.error "not created", err
      )

    getContent: (id, key) ->
      this._getFileOrFolder(id, key).then(
        (doc) =>
          assert(doc.data?, "doc.data is undefined")
          return doc.data
        (err) =>
          return "folder does not exist"
      )

    createFile: (name, content, parentId, key) ->
      this._getFileOrFolder(parentId, key).then(
        (parent) =>
          console.log "parent", parent
          assert(parent?, "parent is undefined")
          unless name in parent.data
            newFile = {
              data: if content? then content else ""
            }
            this._saveFileOrFolder(newFile, key)
            .then (_id) =>
              parent.data.push(_id)
              this._saveFileOrFolder(parent, key)
        (err) =>
          return "parent does not exist"
      )
    createFolder: (name, parentId, key) ->
      this.createFile(name, [], parentId, key)

    createRootFolder: (masterKey) ->
      assert(masterKey?, "masterKey is undefined")
      this._saveFileOrFolder({data: []}, masterKey)
      .then (rootId) =>
        console.log rootId, rootId
        assert(rootId?, "rootId is undefined")
        this.createFile("README", "Welcome", rootId, masterKey)
        .then (fileId) =>
          this._saveFileOrFolder({data: [fileId]}, masterKey)
  }
)
