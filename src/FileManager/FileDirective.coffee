angular.module('fileManager').
directive('file', ($state, session, fileManager, usSpinnerService, Selection, Clipboard)->
  return {
    restrict: 'E'
    replace: true
    scope: {
      file: '='
    }
    template: """
              <div class="file" ng-dblclick="explorer.openFileOrFolder(file)" ng-click="selectFile($event)"
              ng-class="{'is-selected': Selection.hasFile(file), 'file-list': isList(), 'file-thumb': isThumb(), 'is-cut': Clipboard.fileIsCut(file)}"
              draggable="true">
                <div context-menu="selectFile({}, true)" data-target="fileMenu">
                  <div class="file-icon">
                    <span ng-if="isThumb()" us-spinner spinner-key="{{file.metadata.name}}">
                      <img class="file-icon" ng-src="{{ fileIcon }}" draggable="false"/>
                    </span>
                    <span ng-if="isList()"  us-spinner="spinnerListConfig" spinner-key="{{file.metadata.name}}">
                      <img class="file-icon" ng-src="{{ fileIcon }}" draggable="false"/>
                    </span>
                  </div>

                  <div class="file-title" ng-hide="isEditMode()" ng-if="isList()">{{ file.metadata.name }}</div>
                  <div class="file-title" ng-hide="isEditMode()" ng-if="isThumb()" >{{ file.metadata.name |ellipsis:18 }}</div>
                  <input type="text" ng-model="newName" ng-show="isEditMode()" ng-blur="changeName(true)" ng-keypress="changeName($event)" select="isEditMode()"/>

                  <div class="file-size" ng-if="!file.isFolder() && isList()">{{ file.metadata.size |size }}</div>
                </div>
              </div>
              """
    link: (scope, element, attrs)->
      scope.Clipboard = Clipboard
      scope.Selection = Selection
      scope.newName   = scope.file.metadata.name
      scope.explorer  = fileManager

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
        scope.selectFile() if not Selection.hasFile(scope.file)
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

      scope.selectFile = ($event = {}, contextMenu = false) ->
        Selection.select(scope.file, $event.ctrlKey, contextMenu)
        $event.preventDefault?()
        $event.stopPropagation?()

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

      iconPath = (icon) ->
        'images/icon_' + icon + '_48.svg'

      getFileIcon = () ->
        if scope.file.metadata.thumb
          return scope.file.metadata.thumb
        if scope.file.isFolder()
          fileType = 'folder'
        else
          switch scope.file.metadata.name.split('.')[-1..][0]
            when "pdf" then fileType = "pdf"
            else fileType = "text"
        return iconPath fileType

      scope.$watch 'file', () =>
        if scope.file.loading
          usSpinnerService.spin(scope.file.metadata.name)
        else
          usSpinnerService.stop(scope.file.metadata.name)
        scope.fileIcon = getFileIcon()

      #scope.downloadUrl = 'data:' + scope.file.mime + ';charset=utf-8,' + encodeURIComponent(scope.file.getContent())
      scope.file.getFileImg = () ->
        element.find('img')[0]
  }
)
