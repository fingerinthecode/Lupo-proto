angular.module('fileManager').
controller('FileManagerCtrl', ($scope, session, fileManager, account) ->
  account.signIn("i", "i").then =>
    assert(session.isConnected(), "must be connected")
    console.log session.getRootFolder(), session
    fileManager.getContent(session.getRootFolder()).then (content) =>
      $scope.root = content
      console.log("root", $scope.root)

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
)