angular.module('fileManager')
.directive 'dropZone', (Uploader, notification, fileManager, Prompt) ->
  {
    restrict: 'A'
    link: (scope, elem, attr, ctrl) ->
      elem.attr('droppable', true)
      elem.on 'dragover', (evt) ->
        evt.dataTransfer.dropEffect = 'copy' # Explicitly show this is a copy
        evt.stopPropagation()
        evt.preventDefault()

      elem.on 'drop', (evt) ->
        for file in evt.dataTransfer.files
          if file.size > 10000000
            notification.addAlert("The file is too big. Can't upload a file larger than 10MB.", 'danger')
            continue
          name = fileManager.uniqueName(file.name)
          if file.name != name
            Prompt.ask('This name already exist', "#{name} ?", {erase: "Erase", unique: name}).then(
              (type)->
                if type == 'unique'
                  file.name = name
                  Uploader.uploadFile(file)
                else
                  for f in fileManager.fileTree
                    if f.metadata.name == file.name
                      console.info f, file
            )
          else
            Uploader.uploadFile(file)
        evt.stopPropagation()
        evt.preventDefault()
  }
