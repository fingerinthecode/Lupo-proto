angular.module('fileManager').
directive('zoneSelection', (Selection, $document)->
  return {
    restrict: 'A'
    link: (scope, element, attrs)->
      w    = window
      e    = window.document.documentElement
      g    = window.document.getElementsByTagName('body')[0]
      body = window.document.getElementsByTagName('body')[0]
      zone = window.document.getElementById('zone')
      scope.last = 0

      # Creation
      if not zone?
        zone = window.document.createElement('div')
        zone.className = "zone-selection"
        zone.setAttribute('id', 'zone')

      # IsInSelection
      isInSelection = (file)->
        x = w.innerWidth || e.clientWidth || g.clientWidth
        y = w.innerHeight|| e.clientHeight|| g.clientHeight

        selection = zone.getBoundingClientRect()
        selection.right  = x-selection.right
        selection.bottom = y-selection.right

        file = file.getBoundingClientRect()
        file.right  = x-file.right
        file.bottom = y-file.bottom

        if (file.top <= selection.top <= file.bottom or
        file.top <= selection.bottom <= file.bottom or
        selection.top <= file.top <= file.bottom <= selection.bottom) and
        (selection.left <= file.left <= selection.right or
        selection.left <=  file.right <= selection.right or
        file.left <= selection.left <= selection.right <= file.right)
          return true

        return false

      element.on('mousedown', ($event)->
        if ($event.buttons == 1 or $event.button == 0) and
        $event.target == element[0]
          Selection.clear()
          body.appendChild(zone)
          scope.start = $event
          scope.files = window.document.getElementsByClassName('file')
      )
      $document.on('mousemove', ($event)->
        actual = new Date().getTime()
        if scope.start? and scope.last+50<actual
          scope.last = actual
          scope.end  = $event

          x = w.innerWidth || e.clientWidth || g.clientWidth
          y = w.innerHeight|| e.clientHeight|| g.clientHeight

          if scope.start.clientY < scope.end.clientY
            zone.style.top    = "#{scope.start.clientY}px"
            zone.style.bottom = "#{y-scope.end.clientY}px"
          else
            zone.style.top    = "#{scope.end.clientY}px"
            zone.style.bottom = "#{y-scope.start.clientY}px"

          if scope.start.clientX < scope.end.clientX
            zone.style.left  = "#{scope.start.clientX}px"
            zone.style.right = "#{x-scope.end.clientX}px"
          else
            zone.style.left  = "#{scope.end.clientX}px"
            zone.style.right = "#{x-scope.start.clientX}px"

          for file in scope.files
            obj = angular.element(file).scope().file
            if isInSelection(file)
              Selection.add(obj)
            else
              Selection.remove(obj)
      )
      $document.on('mouseup', ($event)->
        angular.element(zone).remove?()
        zone.style = {}
        scope.start = null
      )
  }
)
