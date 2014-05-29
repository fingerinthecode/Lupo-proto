angular.module('fileManager')
.directive('breadcrumb', ($location)->
  return {
    restrict: 'E'
    scope: true
    template: '<ol class="breadcrumb">' +
                '<li ng-repeat="piece in breadcrumb" class="breadcrumb-part" ng-class="{active: $last}">' +
                  '<a ng-if="!$last" ng-href="#{{piece.link}}">{{piece.value}}</a>' +
                  '<span ng-if="$last">{{piece.value}}</span>' +
                '</li>' +
              '</ol>'
    link: (scope, element, attrs) ->
        #scope.$on('$routeChangeSuccess', ->
        path = $location.path()

        breadcrumb = path.split('/').splice(2)

        result = []
        link   = ''
        for piece in breadcrumb
          link += '/' + piece
          add=
            link: link.replace('#', '%23')
            value: piece
          result.push(add)

        scope.breadcrumb = result
        #)
  }
)