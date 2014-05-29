angular.module('fileManager')
.directive('filetree', ($compile, $location)->
  return {
    restrict: 'E'
    scope: {
      tree: '='
    }
    template: '<ol>' +
                '<li ng-repeat="element in tree" class="tree-element tree-element-directory-close">' +
                  '<span class="tree-element-title">{{ element.name }}</span>' +
                  '<div class="tree-element-content">' +
                    '<filetree tree="element.content"></filetree>' +
                  '</div>' +
                '</li>' +
              '</ol>'
    ###
    link: (scope, element, attrs) ->
      console.log "tree", scope.tree
      scope.deepLevel = 0

      scope.$on('$routeChangeSuccess', ->
        path = $location.path()

        breadcrumb = path.split('/').splice(1)

        result = []
        link   = ''
        for piece in breadcrumb
          link += '/' + piece
          add=
            link: link.replace('#', '%23')
            value: piece
          result.push(add)

        scope.breadcrumb = result
      )
    ###
    compile: (tElement, tAttr) ->
      contents = tElement.contents().remove()
      (scope, iElement, iAttr) ->
        unless compiledContents?
          compiledContents = $compile(contents)
        compiledContents(scope, (clone, scope) ->
          console.log iElement, clone
          iElement.append(clone)
        )
  }
)