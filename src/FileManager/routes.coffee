angular.module('fileManager')
.config ($stateProvider) ->
  $stateProvider
    .state('files', {
      url:         '/files/*path'
      templateUrl: 'partials/files.html'
      controller:  'FileManagerCtrl'
      loginRequired: true
    })
    .state('download', {
      url:         '/files{path:.*}'
      templateUrl: 'partials/download.html'
      controller:  'FileDownloadCtrl'
    })
