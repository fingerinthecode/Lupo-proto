angular.module('fileManager').
controller('FileManagerCtrl', ($scope, $stateParams, session, fileManager, $document, $window) ->
  $scope.selected = {
    files: {}
    clipboard: {}
  }
  if session.isConnected()
    explorer = fileManager.getInstance($stateParams.path, $scope, "explorer")

  # -------------Shortcut-----------
  $document.on('keypress', ($event)->
    if $event.ctrlKey or $event.metaKey
      switch $event.charCode
        when 120 then $scope.cutFiles()    # + X
        when 99  then $scope.copyFiles()   # + C
        when 120 then $scope.pasteFiles()  # + V
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
  $scope.singleSelect = ->
    return Object.keys($scope.selected.files).length > 1

  $scope.clipboardNotEmpty = ->
    return Object.keys($scope.selected.clipboard).length == 0

  $scope.openFile = ->
    for key, file of $scope.selected.files
      file.getContent().then (content) =>
        blob = new Blob([content])
        url = URL.createObjectURL(blob)
        $window.open(url, file.metadata.name)

  $scope.renameFile = ->
    for key, file of $scope.selected.files
      file.nameEditable = true

  $scope.shareFiles = ->
    for key, file of $scope.selected.files
      file.share('Bob')

  $scope.cutFiles = ->
    $scope.selected.clipboard = {}
    $scope.selected.clipboard.cut = angular.copy($scope.selected.files)
    $scope.selected.files = {}

  $scope.copyFiles = ->
    $scope.selected.clipboard = {}
    $scope.selected.clipboard.copy = angular.copy($scope.selected.files)
    $scope.selected.files = {}

  $scope.pasteFiles = ->
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

  $scope.deleteFiles = ->
    for key, file of $scope.selected.files
      file.delete()
)
