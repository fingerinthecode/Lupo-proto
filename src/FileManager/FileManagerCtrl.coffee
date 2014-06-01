angular.module('fileManager').
controller('FileManagerCtrl', ($scope, $stateParams, $state, session, fileManager, account) ->
  #$scope.listFolderContent = (folder) ->
  #  fileManager.listFolderContent(folder).then (content) =>

  updatedPath = ->
    console.log "updatePath", $scope.fileTree
    path = "/#{$stateParams.path}"
    path = path.split('/')

    save   = ''
    parent = $scope.explorer.fileTree
    for part in path
      if part isnt ''
        for child in parent ? []
          if child.name == part and
          child.type == 'dir'
            save  += "/#{part}"
            parent = child.content ? []
            break

    if "/#{$stateParams.path}" isnt save
      $state.go('.', {
        path: save
      })

    $scope.files = parent


  $scope.$watch($stateParams, ->
    #updatedPath()
  )

  $scope.isRoot = ->
    path = $stateParams.path
    return path is '' or path is '/'

  $scope.goBack = ->
    window.history.go(-1)

  $scope.goForward = ->
    window.history.go(+1)

  $scope.goParent = ->
    path = $stateParams.path.split('/')
    path.pop()
    path = path.join('/')
    $state.go('.', {
      path: path
    }, {
      location: true
    })

  unless session.isConnected()
    #TMP autologin
    account.signIn("user6", "user6").then =>
      #assert(session.isConnected(), "must be connected")
      explorer = fileManager.getInstance($stateParams.path, $scope, "explorer", updatedPath)

  else
    explorer = fileManager.getInstance($stateParams.path, $scope, "explorer", updatedPath)


)
###
$scope.fileTree = [
  {
    name: 'Music'
    type: 'dir'
    path: '/Music'
    content: [
      {
        name: "test"
      }
    ]
  }
  {
    name: 'Documents'
    type: 'dir'
    path: '/Documents'
    content: [
      {
        name: 'Test'
        type: 'dir'
        path: '/Documents/Test'
        content: [
          {
            name: "test"
          }
        ]
      }
    ]
  }
]
###