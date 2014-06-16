angular.module('fileManager').
factory('Selection', ()->
  return class Selection
    @_files: {}
    @number: 0

    @add: (file)->
      if not @hasFile(file)
        @_files[file._id] = file
        @number++

    @remove: (file)->
      if @hasFile(file)
        delete @_files[file._id]
        @number--

    @clear: ->
      @_files  = {}
      @number = 0

    @hasFile: (file)->
      return @_files.hasOwnProperty(file._id)

    @select: (file, ctrl = false, contextMenu = false) ->
      if contextMenu and @hasFile(file)
        return true

      if not ctrl
        @clear()

      if not @hasFile(file)
        @add(file)
      else
        @remove(file)

    @isSingle: ->
      return @_number == 1

    @isMultiple: ->
      return @_number > 1

    @hasAtLeastOneFolder: ->
      for i, file of @_files
        if file.isFolder()
          return true
          break
      return false
)
