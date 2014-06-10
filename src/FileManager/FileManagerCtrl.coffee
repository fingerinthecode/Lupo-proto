angular.module('fileManager').
controller('FileManagerCtrl', ($scope, $state, $stateParams, session, fileManager, $document, History, User, $q, notification) ->
  unless session.isConnected()
    return

  User.all().then (list) =>
    $scope.users = list
  $scope.share = []
  $scope.selected = {
    files: {}
    clipboard: {}
  }
  $scope.explorer = fileManager.updatePath()
  $scope.History  = History

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
      if user.name.match(reg) and
      user.name != session.user.username
        results.push(user)
    defer.resolve(results)
    return defer.promise

  $scope.isRoot = ->
    path = $stateParams.path
    return path is '' or path is '/'

  # -------------Display Mode--------
  $scope.toList = ->
    session.set('displayThumb', false)

  $scope.toThumb = ->
    session.set('displayThumb', true)

  # ---------Context-Menu------------
  $scope.singleSelect = ->
    return Object.keys($scope.selected.files).length > 1

  $scope.clipboardNotEmpty = ->
    return Object.keys($scope.selected.clipboard).length == 0

  $scope.openFile = ->
    for i, file of $scope.selected.files
      if not file.isFolder()
        $scope.explorer.openFile(file)
      else
        file.openFolder()

  $scope.renameFile = ->
    for key, file of $scope.selected.files
      file.nameEditable = true

  $scope.modalShare = ->
    $scope.shareModal = true
    if Object.keys($scope.selected.files).length == 1
      for _id, file of $scope.selected.files
        if file.metadata.sharedWith?
          $scope.share = ({name: name} for name in file.metadata.sharedWith)
          break

  $scope.closeModalShare = ->
    $scope.shareModal = false

  $scope.shareFiles = ->
    $scope.closeModalShare()
    for user in $scope.share
      for _id, file of $scope.selected.files
        file.share(user.name)
    $scope.share = []
    notification.addAlert('File(s) Shared', 'success')

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
        $scope.explorer.moveFile(file, current_id)
    # Paste from Copy
    else if $scope.clipboard.copy?
      for key, file of $scope.clipboard.cut
        console.log file
    # Clear Clipboard
    $scope.clipboard = {}

  $scope.deleteFiles = ->
    for key, file of $scope.selected.files
      $scope.explorer.deleteFile(file)


  window.onbeforeunload = ->
    return 'If you reload you will loose the selection and other thing. Are you sure ?'
)
