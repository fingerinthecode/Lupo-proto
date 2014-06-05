angular.module('fileManager', ['pouchdb', 'session', 'directive'])
.config ($sceDelegateProvider) ->
  $sceDelegateProvider.resourceUrlWhitelist [
    'self'
    'blob:*'
  ]