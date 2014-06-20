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
      if typeof file == 'object'
        id = file._id
      else
        id = file
      return @_files.hasOwnProperty(id)

    @select: (file, ctrl = false, contextMenu = false) ->
      if contextMenu and @hasFile(file)
        return true
      @clear() if not ctrl
      if not @hasFile(file)
        @add(file)
      else
        @remove(file)

    @isEmpty: ->
      return @number == 0

    @isSingle: ->
      return @number == 1

    @isMultiple: ->
      return @number > 1

    @forEach: (callback)->
      for id, file of @_files
        callback(file)

    @getSize: ->
      total = 0
      for id, file of @_files
        total += file.metadata.size ? 0
      return total

    @getFirst: ->
      for i, file of @_files
        return file

    @hasAtLeastOneFolder: ->
      for i, file of @_files
        if file.isFolder()
          return true
      return false
)
