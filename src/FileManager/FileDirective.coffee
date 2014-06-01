angular.module('fileManager').
directive('file', ($state, $stateParams)->
  return {
    restrict: 'E'
    replace: true
    scope: {
      file: '='
    }
    template: """
              <div class="file file-list" ng-dblclick="go()" nb-click="selected = !selected" ng-class="{selected: selected}">
                <div class="file-icon" context-menu data-target="fileMenu">
                  <img ng-src="images/icon_{{ fileType }}_24.svg" alt="icon" />
                </div>
                <div class="file-title" context-menu data-target="fileMenu">{{ file.metadata.name }}</div>
                <span class="file-size">{{ size }}</span>
                <button ng-click="file.rename('toto.pdf')">RenameToToto</button>
                <button ng-click="file.move('8DB8676E-71D0-4E3D-8663-87C21CB566C6')">MoveToParent</button>
              </div>
              """
    link: (scope, element, attrs)->
      scope.selected = false

      if scope.file.isFolder()
        scope.fileType = 'folder'
      else
        switch scope.file.metadata.name.split('.')[-1..][0]
          when "pdf" then scope.fileType = "pdf"
          else scope.fileType = "text"

        unity = 'B'
        size = scope.file.metadata.size
        if size > 1000
          size /= 1000
          unity = 'KB'
          if size > 1000
            size /= 1000
            unity = 'MB'

        scope.size = Math.round(size*10)/10 + unity

      scope.go = ->
        if scope.file.isFolder()
          $state.go('.', {
            path: "/#{scope.file._id}"
          }, {
            location: true
          })

  }
)
