angular.module('fileManager')
.config ($stateProvider) ->
  $stateProvider
    .state('explorer', {
      url:         '/files'
      templateUrl: 'partials/explorer.html'
      controller:  'ExplorerCtrl'
      redirectTo:  'explorer.files'
    })
    .state('explorer.files', {
      url:         '/{path:.*}'
      templateUrl: 'partials/files.html'
      controller:  'FilesCtrl'
      loginRequired: true
    })
