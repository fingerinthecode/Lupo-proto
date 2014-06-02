angular.module('lupo-proto').
controller('ContainerCtrl', ($scope, $rootScope, session, notification)->
  $scope.user = session.user.public

  lang = window.navigator.language.split('-')[0]
  $rootScope.$broadcast('$ChangeLanguage', lang)
  $rootScope.$on('$translateChangeError', ($event, lang)->
    notification.addAlert("The language doesn't exist")
    if lang isnt 'en'
      $rootScope.$broadcast('$ChangeLanguage', 'en')
  )
)
