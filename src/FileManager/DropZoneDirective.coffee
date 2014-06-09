angular.module('fileManager')
.directive 'dropZone', ($q) ->
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

      arrayBuffer2String = (buffer) ->
        bytes = new Uint8Array(buffer)
        length = bytes.length
        binaryString = ""
        for i in [0..length-1]
          binaryString += String.fromCharCode(bytes[i])
        return binaryString

      elem.bind 'drop', (evt) ->
        evt.stopPropagation()
        evt.preventDefault()
        files = evt.dataTransfer.files

        for file in files
          console.log "will load", file
          ( (file) ->
            reader = new FileReader()
            reader.onloadend = (evt) ->
              if (evt.target.readyState == FileReader.DONE) # DONE == 2
                console.log(file.size)

                strResult = arrayBuffer2String(evt.target.result)
                scope.explorer.addFile(file, strResult)
                console.log strResult.length, strResult


            reader.readAsArrayBuffer(file)
          )(file)
  }
