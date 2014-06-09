angular.module('fileManager')
.config ($stateProvider) ->
  $stateProvider
    .state('files', {
      url:         '/files{slash:/?}{path:.*}'
      templateUrl: 'partials/files.html'
      controller:  'FileManagerCtrl'
      loginRequired: true
    })
