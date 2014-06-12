angular.module('info').
directive('info', ($rootScope, $state, $filter)->
  return {
    restrict: 'E'
    replace: true
    template: """
              <div class="info" ng-hide="close">
                <button class="button-link close" ng-click="close=true">&times;</button>
                <div class="info-content" ng-bind-html="html"></div>
              </div>
              """
    link: (scope, element, attrs)->
      scope.close = false
      scope.drag  = false
      scope.html  = ""

      scope.refresh = ($event)->
        name = $state.current.name.toUpperCase()
        key  = "INFO_#{name}"
        html = $filter('translate')(key)
        if html != key
          scope.html = html
        else
          scope.html = ""

      $rootScope.$on('$stateChangeSuccess', scope.refresh)
      $rootScope.$on('$translateChangeSuccess', scope.refresh)

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
