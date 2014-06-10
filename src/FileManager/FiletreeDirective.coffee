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
    link: (scope, element, attr)->

      scope.loadChilds = (file)->
        file.listContent().then(
          (childs)->
            results = []
            for child in childs
              if child.isFolder()
                results.push(child)
            file.childs = results
          ,(err)->
            console.info err
        )
  }
)
