angular.module('fileManager')
.directive('breadcrumb', (File, session, $filter, $rootScope)->
  return {
    restrict: 'E'
    replace: true
    template: """
              <div class="breadcrumb">
                  <div class="breadcrumb-separator"><i class="icon icon-arrow-right"></i></div>
                <span ng-repeat="piece in breadcrumb">
                  <div class="breadcrumb-part" ng-class="{'is-active': $last}" ui-sref="explorer.files({path: piece._id})">{{ piece.name }}</div>
                  <div class="breadcrumb-separator"><i class="icon icon-arrow-right"></i></div>
                </span>
              </div>
              """

    link: (scope, element, attrs) ->
      $rootScope.$on('$stateChangeSuccess', ($event, toState, toParams)->
        if session.isConnected() and toState.name == 'explorer.files'
          scope.breadcrumb = []
          path = toParams.path
          if path == 'shares'
            scope.breadcrumb.unshift({
              _id:  "shares"
              name: $filter('translate')("Shares")
            })
          else if path != ''
            File.getFile(path).then(
              (file)->
                getPath(file)
              (err)->
                console.error err
            )
      )

      getPath = (file) ->
        if file._id == session.getRootFolderId()
          return true
        scope.breadcrumb.unshift({
          _id:  file._id
          name: file.metadata.name
        })
        file.getParent().then(
          (parent)->
            getPath(parent)
          (err)->
            console.error err
        )
  }

)
