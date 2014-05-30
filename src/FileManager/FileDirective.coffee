angular.module('fileManager').
directive('file', ($state, $stateParams)->
  return {
    restrict: 'E'
    replace: true
    scope: {
      file: '='
    }
    template: """
              <div class="file file-list" ng-dblclick="go()">
                <div class="file-icon">icon</div>
                <div class="file-title">{{ file.name }}</div>
              </div>
              """
    link: (scope, element, attrs)->
      scope.go = ->
        if scope.file.type == 'dir'
          $state.go('.', {
            path: "#{$stateParams.path}/#{scope.file.name}"
          }, {
            location: true
          })
  }
)
