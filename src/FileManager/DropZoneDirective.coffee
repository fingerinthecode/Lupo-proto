angular.module('fileManager')
.directive 'dropZone', ->
  {
    restrict: 'A'
    scope: {
      explorer: '=dropZone'
    }
    link: (scope, elem, attr, ctrl) ->
      elem.bind 'dragover', (evt) ->
        evt.stopPropagation()
        evt.preventDefault()
        evt.dataTransfer.dropEffect = 'copy' # Explicitly show this is a copy

      elem.bind 'drop', (evt) ->
        evt.stopPropagation()
        evt.preventDefault()
        files = evt.dataTransfer.files

        for file in files
          console.log "will load",file
          reader = new FileReader()
          reader.onloadend = (evt) ->
            if (evt.target.readyState == FileReader.DONE) # DONE == 2
              console.log(file.size)
              console.log evt.target.result
              scope.explorer.addFile(file, evt.target.result)

          blob = file.slice(0, file.size - 1)
          reader.readAsBinaryString(blob)
  }
