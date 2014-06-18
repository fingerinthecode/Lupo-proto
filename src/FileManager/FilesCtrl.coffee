angular.module('fileManager').
controller('FilesCtrl', ($scope, session, fileManager, Clipboard, Selection, $document, User, $q, notification)->
  unless session.isConnected()
    return false

  # -------------Shortcut-----------
  $document.on('keypress', ($event)->
    if not ($event.ctrlKey or $event.metaKey)
      switch $event.keyCode
        when 113 then $scope.renameFile() # F2
  )

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

  # Share: list of users
  $scope.share = []
  userList     = []
  User.all().then (list) =>
    for u in list
      u.name = u.name + ' (id: ' + u._id[0..2] + ')'
      userList.push u

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
        file.share(user.name)
    $scope.share = []
    notification.addAlert('File(s) Shared', 'success')
)
