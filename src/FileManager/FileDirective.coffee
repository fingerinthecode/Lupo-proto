angular.module('fileManager').
directive('file', ($state, session, fileManager, Selection, Clipboard)->
  return {
    restrict: 'E'
    replace: true
    scope: {
      file: '='
    }
    template: """
              <div class="file" ng-dblclick="explorer.openFileOrFolder(file)" ng-click="selectFile($event)"
              ng-class="{
                'is-selected': Selection.hasFile(file),
                'file-list': isList(),
                'file-thumb': isThumb(),
                'is-cut': Clipboard.fileIsCut(file),
                'is-loading': file.loading,
              }"
              draggable="true">
                <div context-menu="selectFile({}, true)" data-target="fileMenu">
                  <div class="file-icon">
                    <img  ng-class="{
                      'file-icon-landscape': isIconLandscape(),
                      'file-icon-portrait':  isIconPortrait(),
                    }" ng-src="{{ fileIcon }}" draggable="false"/>
                    <span ng-if="isThumb() && file.loading" us-spinner></span>
                    <span ng-if="isList()  && file.loading" us-spinner="spinnerListConfig"></span>
                  </div>

                  <div class="file-text">
                    <div class="file-title" ng-hide="isEditMode()" ng-if="isList()">{{ file.metadata.name }}</div>
                    <div class="file-title" ng-hide="isEditMode()" ng-if="isThumb()" title="{{file.metadata.name}}">{{ file.metadata.name |ellipsis:15 }}</div>
                    <input type="text" ng-model="newName" ng-show="isEditMode()" ng-blur="changeName(true)" ng-keypress="changeName($event)" select="isEditMode()"/>

                    <div class="file-size" ng-if="!file.isFolder() && isList()">{{ file.metadata.size |size }}</div>
                  </div>
                </div>
              </div>
              """
    link: (scope, element, attrs)->
      scope.Clipboard     = Clipboard
      scope.Selection     = Selection
      scope.newName       = scope.file.metadata.name
      scope.explorer      = fileManager
      scope.iconlandscape = null

      scope.spinnerListConfig = {
        lines:  9
        length: 8
        width:  4
        radius: 7
      }

      scope.isIconLandscape = ->
        if scope.iconlandscape != null
          return scope.iconlandscape

        img = new Image()
        img.src = scope.fileIcon
        if img.width == 0 or img.height == 0
          return true
        if img.width >= img.height
          scope.iconlandscape = true
          return true
        else
          scope.iconlandscape = false
          return false

      scope.isIconPortrait = ->
        return !scope.isIconLandscape()

      scope.isThumb = ->
        return !!session.get('displayThumb')

      scope.isList = ->
        return not session.get('displayThumb')

      # ------------------DragAndDrop----------------------------
      element.on('dragstart', ($event)->
        $img = element.find('img')
        $event.dataTransfer.effectAllowed = "move"
        $event.dataTransfer.setData('unused', "unused")
        $event.dataTransfer.setDragImage($img[0], 10, 10)
        scope.selectFile() if not Selection.hasFile(scope.file)
      )
      element.on('dragover', ($event)->
        if scope.file.isFolder() and
        not Selection.hasFile(scope.file)
          element.attr('droppable', true)
          $event.dataTransfer.dropEffect = 'move'
        else
          element.attr('droppable', false)
          $event.dataTransfer.dropEffect = 'none'
        $event.stopPropagation()
        $event.preventDefault()
      )
      element.on('drop', ($event)->
        Selection.forEach (file)->
          console.info file
          fileManager.moveFile(file, scope.file._id)
        scope.selected = {}
        $event.stopPropagation()
        $event.preventDefault()
      )

      scope.selectFile = ($event = {}, contextMenu = false) ->
        if scope.file.loading
          return false

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
        if $event.keyCode == 13
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
        scope.fileIcon = getFileIcon()

      #scope.downloadUrl = 'data:' + scope.file.mime + ';charset=utf-8,' + encodeURIComponent(scope.file.getContent())
      scope.file.getFileImg = () ->
        element.find('img')[0]
  }
)
