angular.module('fileManager', ['pouchdb', 'session', 'directive', 'ngTagsInput'])
.config ($sceDelegateProvider) ->
  $sceDelegateProvider.resourceUrlWhitelist [
    'self'
    'blob:*'
  ]
