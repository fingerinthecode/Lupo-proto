angular.module('fileManager').
directive('file', ()->
  return {
    restrict: 'E'
    replace: true
    scope: {
      file: '='
      selected: '=selectedFile'
    }
    template: """
              <a ng-href="{{ downloadUrl }}" class="file file-list" ng-dblclick="go()" ng-click="selectFile()" ng-class="{selected: isSelected()}">
                <div class="file-icon" context-menu="selectFile()" data-target="fileMenu" >
                  <img ng-src="images/icon_{{ fileIcon() }}_24.svg" alt="icon" />
                </div>
                <div class="file-title" context-menu="selectFile()"
                    data-target="fileMenu" ng-hide="isEditMode()">{{ file.metadata.name }}</div>
                <form name="changeName" ng-submit="changeName()">
                  <input type="text" ng-model="newName" ng-show="isEditMode()" select="isEditMode()"/>
                </form>
                <span class="file-size">{{ fileSize() }}</span>
                <button ng-click="file.rename('toto.pdf')">RenameToToto</button>
                <button ng-click="file.move('8DB8676E-71D0-4E3D-8663-87C21CB566C6')">MoveToParent</button>
                <button ng-click="file.share('Bob')">Share with Bob</button>
              </a>
              """
    link: (scope, element, attrs)->

      scope.isSelected = () ->
        scope.selected == scope.file

      scope.selectFile = () ->
        scope.selected = scope.file

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

      scope.fileSize = () ->
        unless scope.file.isFolder()
          unity = 'B'
          size = scope.file.metadata.size
          if size > 1000
            size /= 1000
            unity = 'KB'
            if size > 1000
              size /= 1000
              unity = 'MB'

          return Math.round(size*10)/10 + unity

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
