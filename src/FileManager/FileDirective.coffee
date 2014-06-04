angular.module('fileManager').
directive('file', ($state, session)->
  return {
    restrict: 'E'
    replace: true
    scope: {
      file: '='
      selected: '=selectedFiles'
    }
    template: """
              <div class="file" ng-dblclick="go()" ng-click="selectFile($event)" ng-class="{'is-selected': isSelected(), 'file-list': !user.displayThumb, 'file-thumb': user.displayThumb}" draggable="true">
                <div class="file-icon" context-menu="selectFile()" data-target="fileMenu" >
                  <img ng-src="images/icon_{{ fileIcon() }}_24.svg" alt="icon" />
                </div>
                <div class="file-title" context-menu="selectFile()"
                    data-target="fileMenu" ng-hide="isEditMode()">{{ file.metadata.name }}</div>
                <form name="changeName" ng-submit="changeName()">
                  <input type="text" ng-model="newName" ng-show="isEditMode()" select="isEditMode()"/>
                </form>
                <span class="file-size" ng-if="!file.isFolder()">{{ file.metadata.size |size }}</span>
                <button ng-click="file.move('8DB8676E-71D0-4E3D-8663-87C21CB566C6')">MoveToParent</button>
              </div>
              """
    link: (scope, element, attrs)->
      scope.user = session.user
      # ----------------------Selection-------------------------
      ###
      # selectFile
      # $event (optional): javascript click event
      # ifnoselection (optional): keep the selection if not empty
      ###
      scope.selectFile = ($event = {}, ifnoselection = false) ->
        if ifnoselection and Object.keys?(scope.selected).length > 0
          console.log 'disable selection'
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

      scope.isCut = () ->
        cut = scope.clipboard.cut ? {}
        return cut.hasOwnProperty(scope.file._id)

      scope.isEditMode = () ->
        unless scope.isSelected()
          scope.file.nameEditable = false
        scope.isSelected() && scope.file.nameEditable
      scope.newName = scope.file.metadata.name

      scope.changeName = () ->
        scope.file.rename(scope.newName)
        scope.file.nameEditable = false

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
            path: "/#{scope.file._id}"
          }, {
            location: true
          })

      #scope.downloadUrl = 'data:' + scope.file.mime + ';charset=utf-8,' + encodeURIComponent(scope.file.getContent())
  }
)
