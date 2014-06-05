angular.module('fileManager')
.directive('filetree', ($compile, $location)->
  return {
    restrict: 'E'
    scope: {
      tree: '='
    }
    replace: true
    template: """
              <div class="tree">
                <div ng-repeat="element in tree" ng-include="'partials/treeElement.html'"></div>
              </div>
              """
  }
)
