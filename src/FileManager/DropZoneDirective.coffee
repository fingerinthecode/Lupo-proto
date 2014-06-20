angular.module('fileManager')
.directive 'dropZone', ($q, fileManager, File, DeferredQueue, notification) ->
  {
    restrict: 'A'
    scope: {
      explorer: '=dropZone'
    }
    link: (scope, elem, attr, ctrl) ->
      lightTaskQueue = new DeferredQueue(5)
      heavyTaskQueue = new DeferredQueue(1)

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
            img = new Image()
            img.src = evt2.target.result
            img.onload = ->
              resize = (longest, other)->
                q = longest / 180
                other = Math.round(other/q)
                longest = 180
                return [longest, other]

              if img.height > img.width
                [height, width] = resize(img.height, img.width)
              else
                [width, height] = resize(img.width, img.height)
              imgCanvas = document.createElement("canvas")
              imgContext = imgCanvas.getContext("2d")
              imgCanvas.width = width
              imgCanvas.height = height
              imgContext.drawImage(img, 0, 0, width, height)
              dataUrl = imgCanvas.toDataURL(mimeType)
              deferred.resolve([dataUrl, evt2.target.result])

          reader.readAsDataURL(file)
          return deferred.promise

        createLoadingFile = (file)->
          tmpFile = {
            metadata: {
              name: fileManager.uniqueName(file.name)
              size: file.size
              file: file.type
            }
          }
          if file.type == ""
            #FIXME: could be an unknown file type
            tmpFile.metadata.type = File.TYPES.FOLDER
          tmpFile = new File(tmpFile)
          tmpFile.loading = true
          return tmpFile

        uploadFile = (file, loadingFile)->
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

        displayLoadingFile = (loadingFile, thumbDataUrl)->
          if thumbDataUrl?
            loadingFile.metadata.thumb = thumbDataUrl
          fileManager.fileTree.push loadingFile

        for file in files
          console.debug "will load", file
          if file.size > 10000000
            notification.addAlert("The file is too big. Can't upload a file larger than 10MB.", 'danger')
            break
          ( (file) ->
            loadingFile = createLoadingFile file

            if file.type.match('image.*')
              lightTaskQueue.enqueue =>
                createThumbnail file
                .then (dataUrls) =>
                  [thumbDataUrl, dataUrl] = dataUrls
                  displayLoadingFile loadingFile, thumbDataUrl
                  heavyTaskQueue.enqueue => fileManager.addFile(loadingFile.metadata, dataUrl)
            else
              displayLoadingFile(loadingFile)
              heavyTaskQueue.enqueue => uploadFile(file, loadingFile)

          )(file)
  }
