angular.module('fileManager')
.config ($stateProvider) ->
  $stateProvider
    .state('files', {
      url:         '/files{path:.*}'
      templateUrl: 'partials/files.html'
      controller:  'FileManagerCtrl'
    })
