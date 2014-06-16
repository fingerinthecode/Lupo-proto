angular.module('fileManager').
factory('Clipboard', (Selection, fileManager)->
  return class Clipboard
    @_type: ''
    @_files: {}

    @isEmpty: ->
      for id, file in @_files
        return false
        break
      return true

    @clear: ->
      @_files = {}

    @isCut: ->
      return @_type == 'cut'

    @isCopy: ->
      return @_type == 'copy'

    @hasFile: (file)->
      return @_files.hasOwnProperty(file._id)

    @_getSelection: ->
      @_files = angular.copy(Selection._files)
      Selection.clear()

    @cut: ->
      @_type  = 'cut'
      @_getSelection()

    @copy: ->
      @_type  = 'copy'
      @_getSelection()

    @paste: ->
      current_id = fileManager.getCurrentDirId()
      @forEach (file)=>
        if @isCut()
          fileManager.moveFile(file, current_id)
        else
          alert('copy is impossible for the moment')
      @clear()

    @fileIsCut: (file)->
      return @isCut() and @hasFile(file)

    @fileIsCopy: (file)->
      return @isCopy() and @hasFile(file)

    @first: ->
      for id, file of @_files
        return file
        break

    @forEach: (callback)->
      for id, file of @_files
        callback(file)
)
