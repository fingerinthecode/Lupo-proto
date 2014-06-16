angular.module('fileManager')
.directive 'dropZone', ($q, fileManager, File) ->
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

        addFile = (tmpFile, arrayBuffer) ->
          fileManager.fileTree.push tmpFile
          strResult = arrayBuffer2String(arrayBuffer)
          fileManager.addFile(tmpFile.metadata, strResult)
          console.log strResult.length, strResult

        createThumbnail = (data, mimeType) ->
          deferred = $q.defer()
          blob = new Blob [data], {type: mimeType}
          blobReader = new FileReader()
          blobReader.onload = (evt2) =>
            #thumbDataUrl = evt2.target.result
            img = new Image()
            img.src = evt2.target.result
            img.style = "max-height = 90px; max-width = 90px"
            img.onload = ->
              imgCanvas = document.createElement("canvas")
              imgContext = imgCanvas.getContext("2d")
              imgCanvas.width = img.width
              imgCanvas.height = img.height
              imgContext.drawImage(img, 0, 0)
              deferred.resolve(imgCanvas.toDataURL(mimeType))

          blobReader.readAsDataURL(blob)
          return deferred.promise

        for file in files
          console.log "will load", file
          ( (file) ->
            reader = new FileReader()
            reader.onloadend = (evt) ->
              tmpFile = {
                metadata: {
                  name: fileManager.uniqueName(file.name)
                  size: file.size
                }
              }
              if file.type == ""
                #FIXME: could be an unknown file type
                tmpFile.metadata.type = File.TYPES.FOLDER
              else
                tmpFile.metadata.type = File.TYPES.FILE
              tmpFile = new File(tmpFile)
              tmpFile.loading = true

              console.log length, fileManager.fileTree
              if (evt.target.readyState == FileReader.DONE) # DONE == 2
                console.log(file.size)
                if file.type.match('image.*')
                  createThumbnail evt.target.result, file.type
                  .then (thumbDataUrl) =>
                    tmpFile.metadata.thumb = thumbDataUrl
                    addFile tmpFile, evt.target.result
                else
                  addFile tmpFile, evt.target.result

            reader.readAsArrayBuffer(file)
          )(file)
  }
