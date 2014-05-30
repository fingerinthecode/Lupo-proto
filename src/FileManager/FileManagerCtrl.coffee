angular.module('fileManager').
controller('FileManagerCtrl', ($scope, session, fileManager) ->

  $scope.root = fileManager.getContent(session.getRootFolder)

  $scope.fileTree = [
    {
      name: "Music",
      content: [
        {
          name: "test"
        }
      ]
    }
    {
      name: "Documents",
      content: [
        {
          name: "Test"
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