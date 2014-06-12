angular.module('fileManager', ['pouchdb', 'session', 'directive', 'ngTagsInput', 'info', 'ngSanitize'])
.config ($sceDelegateProvider) ->
  $sceDelegateProvider.resourceUrlWhitelist [
    'self'
    'blob:*'
  ]
