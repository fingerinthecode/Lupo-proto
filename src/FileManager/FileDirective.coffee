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
                <div class="file-icon" context-menu data-target="fileMenu" data-target="fileMenu">
                  <img ng-src="images/icon_{{ fileType }}_24.svg" alt="icon" />
                </div>
                <div class="file-title" context-menu data-target="fileMenu" data-target="fileMenu">{{ file.metadata.name }}</div>
                <span class="file-size">{{ file.metadata.size }}</span>
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

      scope.go = ->
        if scope.file.isFolder()
          $state.go('.', {
            path: "/#{scope.file._id}"
          }, {
            location: true
          })

  }
)
