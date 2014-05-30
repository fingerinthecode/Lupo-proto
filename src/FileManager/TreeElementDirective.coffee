angular.module('fileManager').
directive('treeElement', ($stateParams, $state)->
  return {
    restrict: 'E'
    scope: {
      element: '='
    }
    template: """
              <div class="tree-element tree-element-directory-close">
                <button class="btn-link icon icon-arrow-right" ng-click="openElement()" ng-hide="open"></button>
                <button class="btn-link icon icon-arrow-down"  ng-click="openElement()" ng-show="open"></button>
                <span   class="tree-element-title"             ng-click="goTo()">{{ element.name }}</span>
                <div    class="tree-element-content">
                  <divng-repeat="child in element.content">
                    {{child}}
                  </div>
                </div>
              </div>
              """

    link: (scope, element, attrs)->
      scope.open = false
      $container = element.find('tree-element-content')

      scope.openElement = ->
        scope.open = true

      scope.goTo = ->
        $state.go('.', {
          path: scope.element.path
        }, {
          location: true
        })

      scope.closeElement = ->
        scope.open = false


      scope.$watch($stateParams, ->
        expr = new RegExp("^#{scope.element.path}.*")
        if $stateParams.path.match(expr)
          scope.open = true
      )
  }
)
