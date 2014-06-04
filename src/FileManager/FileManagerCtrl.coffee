angular.module('fileManager').
controller('FileManagerCtrl', ($scope, $stateParams, $state, session, fileManager, account) ->

  $scope.selectedFile = null

  updatedPath = ->
    console.log "updatePath", $scope.fileTree
    path = "/#{$stateParams.path}"
    path = path.split('/')

    save   = ''
    parent = $scope.explorer.fileTree
    for part in path
      if part isnt ''
        for child in parent ? []
          if child.name == part and
          child.type == 'dir'
            save  += "/#{part}"
            parent = child.content ? []
            break

    if "/#{$stateParams.path}" isnt save
      $state.go('.', {
        path: save
      })

    $scope.files = parent


  $scope.$watch($stateParams, ->
    #updatedPath()
  )

  $scope.isRoot = ->
    path = $stateParams.path
    return path is '' or path is '/'

  $scope.goBack = ->
    window.history.go(-1)

  $scope.goForward = ->
    window.history.go(+1)

  $scope.goParent = ->
    path = $stateParams.path.split('/')
    path.pop()
    path = path.join('/')
    $state.go('.', {
      path: path
    }, {
      location: true
    })

  if session.isConnected()
    console.log "path", $stateParams.path
    explorer = fileManager.getInstance($stateParams.path || '', $scope, "explorer", updatedPath)
)