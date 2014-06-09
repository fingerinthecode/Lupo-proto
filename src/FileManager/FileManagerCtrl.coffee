angular.module('fileManager').
controller('FileManagerCtrl', ($scope, $state, $stateParams, session, fileManager, $document, $window, History, User, $q) ->
  $scope.users = [{name: 'test'}, {name: 'machin'}, {name: 'truc'}, {name: 'coucou'}, {name: 'pff'}]
  $scope.share = []
  $scope.selected = {
    files: {}
    clipboard: {}
  }
  $scope.History = History
  explorer       = fileManager.getInstance($stateParams.path, $scope, "explorer") if session.isConnected()

  if $stateParams.slash != '/'
    $state.go('.', {
      slash: '/'
    }, {
      location: 'replace'
      reload:   true
    })

  # -------------Shortcut-----------
  $document.on('keypress', ($event)->
    if $event.ctrlKey or $event.metaKey
      switch $event.charCode
        when 120 then $scope.cutFiles()    # + X
        when 99  then $scope.copyFiles()   # + C
        when 120 then $scope.pasteFiles()  # + V
  )

  $scope.loadUsers = ($query)->
    defer   = $q.defer()
    results = []
    for user in $scope.users
      reg = new RegExp("^#{$query}.*")
      if user.name.match(reg)
        results.push(user)
    defer.resolve(results)
    return defer.promise

  $scope.isRoot = ->
    path = $stateParams.path
    return path is '' or path is '/'

  # -------------Display Mode--------
  $scope.toList = ->
    session.user.displayThumb = false

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

  $scope.modalShare = ->
    $scope.shareModal = true
  $scope.closeModalShare = ->
    $scope.shareModal = false

  $scope.shareFiles = ->
    for user in $scope.share
      for file in $scope.selected.files
        file.share(user)

  $scope.cutFiles = ->
    $scope.selected.clipboard = {}
    $scope.selected.clipboard.cut = angular.copy($scope.selected.files)
    $scope.selected.files = {}

  $scope.copyFiles = ->
    $scope.selected.clipboard = {}
    $scope.selected.clipboard.copy = angular.copy($scope.selected.files)
    $scope.selected.files = {}

  $scope.pasteFiles = ->
    current_id = explorer.getCurrentDirId()
    # Paste from Cut
    if $scope.clipboard.cut?
      for key, file of $scope.clipboard.cut
        file.move(current_id)
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
