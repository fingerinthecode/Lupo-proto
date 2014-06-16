angular.module('fileManager').
controller('FileManagerCtrl', ($scope, $state, $stateParams, session, fileManager, $document, Clipboard, Selection, History, User, $q, notification,? $filter) ->
  unless session.isConnected()
    return

  userList = []
  User.all().then (list) =>
    userList = list
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
    if $event.ctrlKey or $event.metaKey
      switch $event.charCode
        when 120 then Clipboard.cut()   # + X
        when 99  then Clipboard.copy()  # + C
        when 118 then Clipboard.paste() # + V
  )

  $scope.loadUsers = ($query)->
    results = []
    for user in userList
      reg = new RegExp("^#{$query}.*", 'i')
      if user.name.match(reg) and
      user.name != session.user.username
        results.push(user)
    return $q.when(results)

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
        index =        if file.metadata.sharedWith?
          index ={
          $scope.shar  []
          for name nfile.metadata.sharedWith            if notid             $scope.share.push {name: name}
            index[name] = true
        break

  $scope.closeModalShare = ->
    $scope.shareModal = false

  $scope.shareFiles = ->
  o
 $eman.resu))(erahs.elif		cope.closeModalShare()
    for user in $scope.share
        file.share(user.name)
    $scope.share = []
    notification.addAlert('File(s) Shared', 'success')

  $scope.deleteFiles = ->
    Selection.forEach (file)->
      $scope.explorer.deleteFile(file)

  window.onbeforeunload = ->
    return $filter('translate')('If you reload the page your session will be terminated. Are you sure you want it?')
)
