angular.module('fileManager').
controller('FilesCtrl', ($scope, session, fileManager, Clipboard, Selection, Shortcut, User, $q, notification, storage)->
  unless session.isConnected()
    return false

  # -------------Shortcut-----------
  Shortcut.on('Ctrl+X', -> Clipboard.cut())
  # Shortcut.on('Ctrl+C', -> Clipboard.copy())
  Shortcut.on('Ctrl+V', -> Clipboard.paste())
  Shortcut.on('F2',     -> $scope.renameFile())
  Shortcut.on('ESC',    -> $scope.renameFile())
  Shortcut.on('DEL',    -> $scope.renameFile())

  $scope.Selection   = Selection
  $scope.Clipboard   = Clipboard
  $scope.fileManager = fileManager

  # Context-Menu
  $scope.openFile = ->
    Selection.forEach (file)->
      fileManager.openFileOrFolder(file)

  $scope.renameFile = ->
    file = Selection.getFirst()
    file.nameEditable = true

  $scope.deleteFiles = ->
    Selection.forEach (file)->
      fileManager.deleteFile(file)
    Selection.clear()

  # Share: list of users
  $scope.share = []
  userList     = []
  User.all().then (list) =>
    for u in list
      u.key = u.name + ' (id: ' + u._id[0..2] + ')'
      userList.push u

  storage.change('newUser', (u)->
    u.key = u.name + ' (id: ' + u._id[0..2] + ')'
    userList.push u
  )

  $scope.loadUsers = ($query)->
    results = []
    reg     = new RegExp("^#{$query}.*", 'i')
    for user in userList
      if user.name.match(reg) and
      user.name != session.user.username
        results.push(user)
    return $q.when(results)

  $scope.modalShare = ->
    $scope.shareModal = true
    if Selection.isSingle()
      file = Selection.getFirst()
      index = {}
      $scope.share = []
      for name in file.metadata.sharedWith ? []
        if not index[name]?
          index[name] = true
          $scope.share.push({name: name})

  $scope.closeModalShare = ->
    $scope.shareModal = false

  $scope.shareFiles = ->
    $scope.closeModalShare()
    for user in $scope.share
      Selection.forEach (file) ->
        fileManager.shareFile(file, user)
    $scope.share = []
    notification.addAlert('File(s) Shared', 'success')
)
