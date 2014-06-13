angular.module('fileManager').
directive('file', ($state, session, fileManager, usSpinnerService)->
  return {
    restrict: 'E'
    replace: true
    scope: {
      file: '='
      selected:  '=selectedFiles'
      clipboard: '=clipboardFiles'
    }
    template: """
              <div class="file" ng-dblclick="explorer.openFileOrFolder(file)" ng-click="selectFile($event)"
              ng-class="{'is-selected': isSelected(), 'file-list': isList(), 'file-thumb': isThumb(), 'is-cut': isCut()}"
              draggable="true">
                <div context-menu="selectFile({}, true)" data-target="fileMenu">
                  <img class="file-icon" ng-src="images/icon_{{ fileIcon() }}_48.svg" alt="icon" draggable="false" ng-hide="file.loading"/>

                  <div class="file-icon" ng-show="file.loading">
                    <span ng-if="isThumb()" us-spinner=""></span>
                    <span ng-if="isList()"  us-spinner="spinnerListConfig"></span>
                  </div>

                  <div class="file-title" ng-hide="isEditMode()" ng-if="isList()">{{ file.metadata.name }}</div>
                  <div class="file-title" ng-hide="isEditMode()" ng-if="isThumb()" >{{ file.metadata.name |ellipsis:18 }}</div>
                  <input type="text" ng-model="newName" ng-show="isEditMode()" ng-blur="changeName(true)" ng-keypress="changeName($event)" select="isEditMode()"/>

                  <div class="file-size" ng-if="!file.isFolder() && isList()">{{ file.metadata.size |size }}</div>
                </div>
              </div>
              """
    link: (scope, element, attrs)->
      scope.user     = session.user
      scope.newName  = scope.file.metadata.name
      scope.explorer = fileManager

      scope.spinnerListConfig = {
        lines:  9
        length: 8
        width:  4
        radius: 7
      }

      scope.isThumb = ->
        return !!session.get('displayThumb')

      scope.isList = ->
        return not session.get('displayThumb')

      # ------------------DragAndDrop----------------------------
      element.on('dragstart', ($event)->
        url = "https://codeload.github.com/LupoLibero/Lupo-proto/zip/master"

        $img = element.find('img')
        $event.dataTransfer.effectAllowed = "move"
        $event.dataTransfer.setData('DownloadURL', "application/zip:#{scope.file.metadata.name}:#{url}")
        $event.dataTransfer.setDragImage($img[0], 10, 10)
        scope.selectFile() if not scope.isSelected()
      )
      element.on('dragover', ($event)->
        if scope.file.isFolder() and
        not scope.selected.hasOwnProperty(scope.file._id)
          element.attr('droppable', true)
          $event.dataTransfer.dropEffect = 'move'
        else
          element.attr('droppable', false)
          $event.dataTransfer.dropEffect = 'none'
        $event.stopPropagation()
        $event.preventDefault()
      )
      element.on('drop', ($event)->
        for _id, file of scope.selected
          fileManager.moveFile(file, scope.file._id)
        scope.selected = {}
        $event.stopPropagation()
        $event.preventDefault()
      )

      # ----------------------Selection-------------------------
      ###
      # selectFile
      # $event (optional): javascript click event
      # ifnoselection (optional): keep the selection if not empty
      ###
      scope.selectFile = ($event = {}, contextMenu = false) ->
        if contextMenu and scope.selected.hasOwnProperty(scope.file._id)
          return true

        if not $event.ctrlKey ? false
          scope.selected = {}

        if not scope.selected.hasOwnProperty(scope.file._id)
          scope.selected[scope.file._id] = scope.file
        else
          delete scope.selected[scope.file._id]

        $event.preventDefault?()
        $event.stopPropagation?()

      scope.isSelected = () ->
        return scope.selected.hasOwnProperty(scope.file._id)

      # -------------------Mode-------------------------
      # If the file is cut
      scope.isCut = () ->
        cut = scope.clipboard.cut ? {}
        return cut.hasOwnProperty(scope.file._id)

      scope.isEditMode = () ->
        return scope.file.nameEditable

      # -------------------Rename-----------------------
      scope.changeName = ($event = {}) ->
        if $event == true or $event.keyCode == 13
          scope.file.rename(scope.newName)
          scope.file.nameEditable = false
          $event.preventDefault()
          $event.stopPropagation()

      scope.fileIcon = () ->
        if scope.file.isFolder()
          return 'folder'
        else
          switch scope.file.metadata.name.split('.')[-1..][0]
            when "pdf" then scope.fileType = "pdf"
            else scope.fileType = "text"

      #scope.downloadUrl = 'data:' + scope.file.mime + ';charset=utf-8,' + encodeURIComponent(scope.file.getContent())

  }
)
