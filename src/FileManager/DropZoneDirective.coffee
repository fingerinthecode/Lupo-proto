angular.module('fileManager')
.directive 'dropZone', (Uploader) ->
  {
    restrict: 'A'
    scope: {}

    link: (scope, elem, attr, ctrl) ->
      elem.on 'dragover', (evt) ->
        evt.dataTransfer.dropEffect = 'copy' # Explicitly show this is a copy
        evt.stopPropagation()
        evt.preventDefault()

      elem.on 'drop', (evt) ->
        Uploader.uploadFiles(evt.dataTransfer.files)
        evt.stopPropagation()
        evt.preventDefault()
  }
