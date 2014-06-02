angular.module('directive').
directive('focus', ->
  return {
    restrict: 'A'
    scope:
      focus: '='
    link: (scope, element, attrs) ->
      scope.$watch('focus', ->
        if scope.focus
          element.focus()
      )
  }
)
