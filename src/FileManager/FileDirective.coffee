angular.module('fileManager').
directive('file', ($state, session)->
  return {
    restrict: 'E'
    replace: true
    scope: {
      file: '='
      selected:  '=selectedFiles'
      clipboard: '=clipboardFiles'
    }
    template: """
              <div class="file" ng-dblclick="go()" ng-click="selectFile($event)"
              ng-class="{'is-selected': isSelected(), 'file-list': !user.displayThumb, 'file-thumb': user.displayThumb, 'is-cut': isCut()}"
              draggable="true">
                <div context-menu="selectFile({}, true)" data-target="fileMenu">
                  <img class="file-icon" ng-src="images/icon_{{ fileIcon() }}_24.svg" alt="icon" draggable="false"/>

                  <div class="file-title" ng-hide="isEditMode()">{{ file.metadata.name }}</div>
                  <input type="text" ng-model="newName" ng-show="isEditMode()" ng-blur="changeName(true)" ng-keypress="changeName($event)" select="isEditMode()"/>

                  <span class="file-size" ng-if="!file.isFolder()">{{ file.metadata.size |size }}</span>
                </div>
              </div>
              """
    link: (scope, element, attrs)->
      scope.user    = session.user
      scope.newName = scope.file.metadata.name

      # ------------------DragAndDrop----------------------------
      element.on('dragstart', ($event)->
        $img = element.find('img')
        $event.dataTransfer.effectAllowed = "move"
        $event.dataTransfer.setData('DownloadURL', "application/zip:Test:https://codeload.github.com/LupoLibero/Lupo-proto/zip/master")
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
        for key, file of scope.selected
          file.move(scope.file._id)
        scope.selected = {}
      )

      # ----------------------Selection-------------------------
      ###
      # selectFile
      # $event (optional): javascript click event
      # ifnoselection (optional): keep the selection if not empty
      ###
      scope.selectFile = ($event = {}, ifnoselection = false) ->
        if ifnoselection and Object.keys?(scope.selected).length > 0
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

      scope.go = ->
        if scope.file.isFolder()
          $state.go('.', {
            path: scope.file._id
          }, {
            location: true
          })

      #scope.downloadUrl = 'data:' + scope.file.mime + ';charset=utf-8,' + encodeURIComponent(scope.file.getContent())
  }
)
