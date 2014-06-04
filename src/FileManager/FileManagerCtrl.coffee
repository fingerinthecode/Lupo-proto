angular.module('fileManager').
controller('FileManagerCtrl', ($scope, $stateParams, session, fileManager, $document) ->
  $scope.selected = {
    files: {}
    clipboard: {}
  }
  if session.isConnected()
    explorer = fileManager.getInstance($stateParams.path, $scope, "explorer")

  # -------------Shortcut-----------
  $document.on('keypress', ($event)->
    if $event.ctrlKey
      if $event.charCode == 120 # Ctrl + X
        $scope.selected.clipboard = {}
        $scope.selected.clipboard.cut = angular.copy($scope.selected.files)
        $scope.selected.files = {}
      else if $event.charCode == 99 # Ctrl + C
        $scope.selected.clipboard = {}
        $scope.selected.clipboard.copy = angular.copy($scope.selected.files)
        $scope.selected.files = {}
      else if $event.charCode == 118 # Ctrl + V
        # Paste from Cut
        if $scope.clipboard.cut?
          for key, file of $scope.clipboard.cut
            console.log file
        # Paste from Copy
        else if $scope.clipboard.copy?
          for key, file of $scope.clipboard.cut
            console.log file
        # Clear Clipboard
        $scope.clipboard = {}
  )

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
