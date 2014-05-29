angular.module('session')
.config ($stateProvider) ->
  $stateProvider
    .state('signin', {
      url:         '/signin'
      templateUrl: 'partials/signin.html'
      controller:  'SignInCtrl'
    })
    .state('signup', {
      url:         '/signup'
      templateUrl: 'partials/signup.html'
      controller:  'SignUpCtrl'
    })