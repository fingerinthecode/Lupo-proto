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
                <tree-element ng-repeat="element in tree" element="element"></tree-element>
              </div>
              """
  }
)
