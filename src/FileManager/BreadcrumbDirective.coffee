angular.module('fileManager')
.directive('breadcrumb', ($stateParams)->
  return {
    restrict: 'E'
    template: """
              <div class="breadcrumb">
                  <div class="breadcrumb-separator"><i class="icon icon-arrow-right"></i></div>
                <span ng-repeat="piece in breadcrumb">
                  <div class="breadcrumb-part" ng-class="{'is-active': $last}" ui-sref=".(piece)">{{ piece.value }}</div>
                  <div class="breadcrumb-separator"><i class="icon icon-arrow-right"></i></div>
                </span>
              </div>
              """

    link: (scope, element, attrs) ->
      scope.$watch($stateParams, ->
        path = "/#{$stateParams.path}"
        path = path.split('/')

        result = []
        link   = ''
        for piece in path
          if piece isnt ''
            link += '/' + piece
            add=
              path: link.replace('#', '%23')
              value: piece
            result.push(add)

        scope.breadcrumb = result
      )

  }
)
