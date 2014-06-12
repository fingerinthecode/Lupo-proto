angular.module('info').
directive('info', ($rootScope, $state)->
  return {
    restrict: 'E'
    replace: true
    template: """
              <div class="info">
                {{ key |translate }}
              </div>
              """
    link: (scope, element, attrs)->
      scope.drag = false
      $rootScope.$on('$stateChangeSuccess', ->
        name      = $state.current.name.toUpperCase()
        scope.key = "INFO_#{name}"
      )

      element.on('mousedown', ($event)->
        scope.drag  = true
        scope.original = {
          left: parseInt(window.getComputedStyle(element[0]).left)
          top:  parseInt(window.getComputedStyle(element[0]).top)
        }
        scope.mouse = {
          x: $event.clientX
          y: $event.clientY
        }
      )
      element.on('mousemove', ($event)->
        if scope.drag
          mouse  = scope.mouse
          origin = scope.original
          console.info scope, origin, mouse, $event
          element.css({
            left: origin.left + $event.clientX - mouse.x + "px"
            top:  origin.top  + $event.clientY - mouse.y + "px"
          })
          $event.stopPropagation()
      )
      element.on('mouseup', ($event)->
        scope.drag = false
      )
      element.on('mouseout', ($event)->
        scope.drag = false
      )

  }
)
