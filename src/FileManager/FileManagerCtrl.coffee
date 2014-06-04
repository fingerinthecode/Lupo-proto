angular.module('fileManager').
controller('FileManagerCtrl', ($scope, $stateParams, session, fileManager, $document) ->
  $scope.selected = {
    files: {}
    clipboard: {}
  }
  if session.isConnected()
    explorer = fileManager.getInstance($stateParams.path, $scope, "explorer")

  # ----------Navigation Button------
  $scope.isRoot = ->
    path = $stateParams.path
    return path is '' or path is '/'

  $scope.goBack = ->
    window.history.go(-1)

  $scope.goForward = ->
    window.history.go(+1)

  $scope.goParent = ->

  # -------------Display Mode--------
  $scope.toList = ->
    session.user.displayThumb = false
    console.log "toList"

  $scope.toThumb = ->
    session.user.displayThumb = true

  # ---------Context-Menu------------
  $scope.openFile = ->

  $scope.shareFiles = ->
    for key, file of $scope.selected.files
      file.share('Bob')

  $scope.renameFile = ->
    for key, file of $scope.selected.files
      file.nameEditable = true
      break

  $scope.deleteFiles = ->
    for key, file of $scope.selected.files
      file.delete()
)
