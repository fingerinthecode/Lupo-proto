angular.module('fileManager').
controller('FileManagerCtrl', ($scope, session) ->
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