angular.module('fileManager').
controller('FileManagerCtrl', ($scope, $state, $stateParams, session, fileManager, $document, Clipboard, Selection, History, User, $q, notification) ->
  unless session.isConnected()
    return

  User.all().then (list) =>
    $scope.users = list
  $scope.share = []

  $scope.explorer  = fileManager.updatePath()
  $scope.History   = History
  $scope.Clipboard = Clipboard
  $scope.Selection = Selection

  if $stateParams.slash != '/'
    $state.go('.', {
      slash: '/'
    }, {
      location: 'replace'
      reload:   true
    })

  # -------------Shortcut-----------
  $document.on('keypress', ($event)->
    console.log $event.charCode
    if $event.ctrlKey or $event.metaKey
      switch $event.charCode
        when 120 then Clipboard.cut()   # + X
        when 99  then Clipboard.copy()  # + C
        when 118 then Clipboard.paste() # + V
  )

  $scope.loadUsers = ($query)->
    defer   = $q.defer()
    results = []
    for user in $scope.users
      reg = new RegExp("^#{$query}.*", 'i')
      if user.name.match(reg) and
      user.name != session.user.username
        results.push(user)
    defer.resolve(results)
    return defer.promise

  $scope.isRoot = ->
    path = $stateParams.path ? ''
    return path is ''

  # -------------Display Mode--------
  $scope.toList = ->
    session.set('displayThumb', false)

  $scope.toThumb = ->
    session.set('displayThumb', true)

  $scope.openFile = ->
    Selection.forEach (file)->
      explorer.openFileOrFolder(file)

  $scope.renameFile = ->
    Selection.forEach (file)->
      file.nameEditable = true

  $scope.modalShare = ->
    $scope.shareModal = true
    if Selection.single()
      file = Selection.first()
      if file.metadata.sharedWith?
        $scope.share = ({name: name} for name in file.metadata.sharedWith)

  $scope.closeModalShare = ->
    $scope.shareModal = false

  $scope.shareFiles = ->
    $scope.closeModalShare()
    for user in $scope.share
      Selection.forEach (file)->
        file.share(user.name)
    $scope.share = []
    notification.addAlert('File(s) Shared', 'success')

  $scope.deleteFiles = ->
    Selection.forEach (file)->
      $scope.explorer.deleteFile(file)

  window.onbeforeunload = ->
    return 'If you reload you will loose the selection and other thing. Are you sure ?'
)
