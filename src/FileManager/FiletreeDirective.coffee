angular.module('fileManager')
.directive('filetree', ($rootScope, $compile, $location, $q, Swipe, $animate, $timeout)->
  return {
    restrict: 'E'
    scope: {
      tree: '='
    }
    replace: true
    template: """
              <div class="tree">
                <div ng-repeat="element in tree |orderBy:'metadata.name'" ng-include="'partials/treeElement.html'"></div>
              </div>
              """
    link: (scope, element, attr)->
      if not Device.desktop()
        enable = true
        $rootScope.$on 'AppMenu:open',  -> enable = false
        $rootScope.$on 'AppMenu:close', -> enable = true

        Swipe.right ($event)->
          if enable
            $animate.addClass(element, 'is-visible', ->
              $rootScope.$broadcast('TreeFile:open')
            )

        Swipe.left ($event)->
          if enable
            $animate.removeClass(element, 'is-visible', ->
              $rootScope.$broadcast('TreeFile:close')
            )

      scope.littleSpinner = {
        lines:  7
        length: 5
        width:  4
        radius: 5
      }

      scope.openFolder = (file)->
        file.open = !file.open
        if file.open
          file.loading = true
          scope.loadChilds(file).then(
            (data)->
              file.loading   = false
            (err)->
              file.open    = false
              file.loading = false
          )

      scope.loadChilds = (file)->
        defer = $q.defer()
        file.listContent().then(
          (childs)->
            results = []
            for child in childs
              if child.isFolder()
                results.push(child)
            file.childs = results
            defer.resolve()
          ,(err)->
            defer.reject(err)
            console.log err
        )
        return defer.promise
  }
)
