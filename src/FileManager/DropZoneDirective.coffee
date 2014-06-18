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

        uploadSlice = (tmpFile, arrayBuffer) ->
          strResult = arrayBuffer2String(arrayBuffer)
          fileManager.addFile(tmpFile.metadata, strResult)
          console.log strResult.length, strResult

        createThumbnail = (file) ->
          mimeType = file.type
          deferred = $q.defer()
          reader = new FileReader()
          reader.onload = (evt2) =>
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

          reader.readAsDataURL(file)
          return deferred.promise

        createLoadingFile = (file)->
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
          return tmpFile

        uploadFile = (file, loadingFile)->
          fileManager.fileTree.push loadingFile
          reader = new FileReader()
          reader.onloadend = (evt) ->
            if (evt.target.readyState == FileReader.DONE) # DONE == 2
              uploadSlice loadingFile, evt.target.result

          #SLICE_SIZE = 1024 * 1024 - 1
          SLICE_SIZE = file.size + 1
          start = 0
          while start < file.size
            blob = file.slice(start, start + SLICE_SIZE - 1)
            reader.readAsArrayBuffer(blob)
            start += SLICE_SIZE

        for file in files
          console.log "will load", file
          ( (file) ->
            loadingFile = createLoadingFile file

            if file.type.match('image.*')
              createThumbnail file
              .then (thumbDataUrl) =>
                loadingFile.metadata.thumb = thumbDataUrl
                uploadFile file, loadingFile
            else
              uploadFile file, loadingFile

          )(file)
  }
