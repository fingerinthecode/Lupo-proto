angular.module('fileManager').
factory 'Uploader', ($q, File, fileManager, DeferredQueue, notification) ->
  {
    arrayBuffer2String: (buffer) ->
      bytes = new Uint8Array(buffer)
      length = bytes.length
      binaryString = ""
      for i in [0..length-1]
        binaryString += String.fromCharCode(bytes[i])
      return binaryString

    createThumbnail: (file) ->
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

    createLoadingFile: (file)->
      tmpFile = {
        metadata: {
          name: fileManager.uniqueName(file.name)
          size: file.size
          type: file.type
        }
      }
      if file.type == ""
        #FIXME: could be an unknown file type
        tmpFile.metadata.type = File.TYPES.FOLDER
      tmpFile = new File(tmpFile)
      tmpFile.loading = true
      return tmpFile

    uploadSlice: (tmpFile, arrayBuffer) ->
      strResult = @arrayBuffer2String(arrayBuffer)
      #strResult = "data:" + tmpFile.type + ';base64,' + btoa(strResult)
      fileManager.addFile(tmpFile.metadata, strResult)
      console.log strResult.length, strResult

    uploadOneFile: (file, loadingFile)->
      @readFileToArrayBuffer(file).then (arrayBuffer) =>
        @uploadSlice loadingFile, arrayBuffer

    readFileToArrayBuffer: (file, sliceSize) ->
      deferred = $q.defer()
      reader = new FileReader()
      if not sliceSize?
        sliceSize = file.size + 1
      alreadyRead = 0
      nbOfSlices = Math.ceil(file.size / sliceSize)
      reader.onloadend = (evt) ->
        if (evt.target.readyState == FileReader.DONE) # DONE == 2
          alreadyRead++
          if alreadyRead < nbOfSlices
            deferred.notify(alreadyRead/nbOfSlices)
          else
            deferred.resolve(evt.target.result)
      start = 0
      while start < file.size
        blob = file.slice(start, start + sliceSize - 1)
        reader.readAsArrayBuffer(blob)
        start += sliceSize
      return deferred.promise

    displayLoadingFile: (loadingFile, thumbDataUrl)->
      if thumbDataUrl?
        loadingFile.metadata.thumb = thumbDataUrl
      fileManager.fileTree.push loadingFile

    uploadFiles: (files) ->
      for file in files
        console.debug "will load", file
        if file.size > 10000000
          notification.addAlert("The file is too big. Can't upload a file larger than 10MB.", 'danger')
          break
        ( (file) =>
          loadingFile = @createLoadingFile file

          if file.type.match('image.*')
            fileManager.lightTaskQueue.enqueue =>
              ###
              @readFileToArrayBuffer file
              .then (arrayBuffer) =>
                @createThumbnail arrayBuffer
                .then (thumbDataUrl) =>
                  @displayLoadingFile loadingFile, thumbDataUrl
                fileManager.heavyTaskQueue.enqueue => @uploadSlice(loadingFile, arrayBuffer)
              ###
              @createThumbnail file
              .then (dataUrls) =>
                [thumbDataUrl, dataUrl] = dataUrls
                @displayLoadingFile loadingFile, thumbDataUrl
                fileManager.heavyTaskQueue.enqueue => fileManager.addFile(loadingFile.metadata, dataUrl)

          else
            @displayLoadingFile(loadingFile)
            fileManager.heavyTaskQueue.enqueue => @uploadOneFile(file, loadingFile)
            fileManager.heavyTaskQueue.enqueue => console.error "FINISHED"
        )(file)

  }