angular.module('lupo-proto').
controller('ContainerCtrl', ($scope, $rootScope, session, notification, $state)->
  $scope.user = session.user.public

  $rootScope.$on('$stateChangeSuccess', ($event, toState, toParams, fromState, fromParams)->
    if toState.loginRequired? and
    not session.isConnected() and
    toState.loginRequired
      session.saveFlash('redirect', [$state.current.name, $state.params])
      $state.transitionTo('signin', {})

    if toState.notConnected? and
    session.isConnected()     and
    toState.notConnected
      if fromState.name isnt ''
        $state.transitionTo(fromState.name, fromParams)
      else
        $state.transitionTo('files', {})
  )

  lang = window.navigator.language.split('-')[0]
  $rootScope.$broadcast('$ChangeLanguage', lang)
  $rootScope.$on('$translateChangeError', ($event, lang)->
    notification.addAlert("The language doesn't exist")
    if lang isnt 'en'
      $rootScope.$broadcast('$ChangeLanguage', 'en')
  )
)
