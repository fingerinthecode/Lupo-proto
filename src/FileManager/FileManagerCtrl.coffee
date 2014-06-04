angular.module('fileManager').
controller('FileManagerCtrl', ($scope, $stateParams, session, fileManager) ->
  $scope.selected = {
    files: {}
    clipboard: {}
  }

  $scope.isRoot = ->
    path = $stateParams.path
    return path is '' or path is '/'

  $scope.goBack = ->
    window.history.go(-1)

  $scope.goForward = ->
    window.history.go(+1)

  $scope.goParent = ->

  $scope.toList = ->
    session.user.displayThumb = false
    console.log "toList"

  $scope.toThumb = ->
    session.user.displayThumb = true

  if session.isConnected()
    explorer = fileManager.getInstance($stateParams.path, $scope, "explorer")
)
