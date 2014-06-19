angular.module('fileManager', ['session', 'directive', 'ngTagsInput', 'info', 'ngSanitize'])
.config ($sceDelegateProvider) ->
  $sceDelegateProvider.resourceUrlWhitelist [
    'self'
    'blob:*'
  ]
