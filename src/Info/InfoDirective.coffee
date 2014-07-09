angular.module('info').
directive('info', ($rootScope, $state, $filter, $document, $timeout, Browser)->
  return {
    restrict: 'E'
    replace: true
    template: """
              <div class="info" ng-hide="close">
                <div class="info-move" style="float:left;margin-left:3px;margin-top:3px;"><i class="icon icon-move"></i></div>
                <button class="button-link close" ng-click="close=true">&times;</button>
                <div class="info-content" ng-bind-html="html"></div>
              </div>
              """
    link: (scope, element, attrs)->
      scope.close = false
      scope.drag  = false
      scope.html  = ""
      $button     = angular.element(element[0].getElementsByClassName('info-move')[0])
      scope.to    = {
        x: 0
        y: 0
      }

      scope.refresh = ($event)->
        scope.html = ""
        $timeout(->
          name = $state.current.name.toUpperCase()
          key  = "INFO_#{name}"
          html = $filter('translate')(key)
          if html != key
            scope.html = html
          else
            scope.html = ""
        , 10)

      $rootScope.$on('$stateChangeSuccess', scope.refresh)
      $rootScope.$on('$translateChangeSuccess', scope.refresh)

      $button.on('mousedown', ($event)->
        scope.drag  = true
        scope.mouse = {
          x: $event.clientX
          y: $event.clientY
        }
      )
      $document.on('mousemove', ($event)->
        # If the mouse is leaving the browser disable the tracking
        if $event.clientX < 0             or
        $event.clientY < 0                or
        $event.clientX > Browser.width()  or
        $event.clientY > Browser.height()
          scope.drag = false

        if scope.drag
          if Browser.haveTransform()
            scope.to = {
              x: scope.to.x + ($event.clientX - scope.mouse.x)
              y: scope.to.y + ($event.clientY - scope.mouse.y)
            }

            move(element[0]).to(scope.to.x, scope.to.y).duration(30).end()
          else
            move(element[0])
              .set('left', $event.clientX - 15 + "px")
              .set('top',  $event.clientY - 15 + "px")
              .duration(30).end()

          scope.mouse = {
            x: $event.clientX
            y: $event.clientY
          }
          $event.stopPropagation()
          $event.preventDefault()
      )
      $document.on('mouseup', ($event)->
        scope.drag = false
      )
 }
)
