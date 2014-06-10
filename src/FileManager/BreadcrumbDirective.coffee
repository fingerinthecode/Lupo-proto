angular.module('fileManager')
.directive('breadcrumb', ($stateParams, File, session)->
  return {
    restrict: 'E'
    template: """
              <div class="breadcrumb">
                  <div class="breadcrumb-separator"><i class="icon icon-arrow-right"></i></div>
                <span ng-repeat="piece in breadcrumb">
                  <div class="breadcrumb-part" ng-class="{'is-active': $last}" ui-sref=".({path: piece._id})">{{ piece.name }}</div>
                  <div class="breadcrumb-separator"><i class="icon icon-arrow-right"></i></div>
                </span>
              </div>
              """

    link: (scope, element, attrs) ->
      scope.breadcrumb = []
      scope.$watch($stateParams, ->
        if session.isConnected()
          scope.breadcrumb = []
          getPath($stateParams.path)
      )

      getPath = (id) ->
        if id != ""
          File.getFile(id).then (file)=>
            scope.breadcrumb.unshift({
              _id:  file._id
              name: file.metadata.name
            })

            parent_id = file.metadata.parentId
            if parent_id? and parent_id != session.getRootFolderId()
              getPath(parent_id)
  }
)
