angular.module('directive').
directive('select', ->
  return {
    restrict: 'A'
    scope:
      select: '='
    link: (scope, element, attrs) ->
      scope.$watch('select', ->
        if scope.select
          element[0].select()
      )
  }
)
