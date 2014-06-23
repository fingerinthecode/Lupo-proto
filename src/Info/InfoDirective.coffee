angular.module('info').
directive('info', ($rootScope, $state, $filter, $document)->
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
      move        = element[0].getElementsByClassName('info-move')[0]
      $move       = angular.element(move)
      page        = window.document.getElementById('page')
      $page       = angular.element(page)

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

      $move.on('mousedown', ($event)->
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
      $document.on('mousemove', ($event)->
        w = window
        d = document
        e = d.documentElement
        g = d.getElementsByTagName('body')[0]
        x = w.innerWidth || e.clientWidth || g.clientWidth
        y = w.innerHeight|| e.clientHeight|| g.clientHeight

        if $event.clientX < 0 or
        $event.clientY < 0    or
        $event.clientX > x    or
        $event.clientY > y
          scope.drag = false

        if scope.drag
          console.info $event
          element[0].style.left = $event.clientX - 10 + "px"
          element[0].style.top  = $event.clientY - 10 + "px"
          $event.stopPropagation()
          $event.preventDefault()
      )
      $document.on('mouseup', ($event)->
        scope.drag = false
      )
 }
)
