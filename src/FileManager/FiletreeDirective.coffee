angular.module('fileManager')
.directive('filetree', ($compile, $location, $q)->
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

      scope.littleSpinner = {
        lines:  7
        length: 5
        width:  4
        radius: 5
      }

      scope.openFolder = (file)->
        file.open = !file.open
        if file.open and not file.loadChild
          file.loading = true
          scope.loadChilds(file).then(
            (data)->
              file.loading   = false
              file.loadChild = true
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
