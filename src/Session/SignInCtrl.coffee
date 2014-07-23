angular.module('session').
controller('SignInCtrl', ($scope, account, Notification, usSpinnerService, session, $state) ->

  $scope.signInSubmit = () ->
    usSpinnerService.spin('main')
    account.signIn($scope.login, $scope.password).then(
      (data) =>
        usSpinnerService.stop('main')
        $state.go('explorer.files', {
          path: ''
        })
      (err) =>
        Notification.addAlert("Incorrect login/password")
        usSpinnerService.stop('main')
    )

  $scope.login    = 'test'
  $scope.password = 'test'
  $scope.signInSubmit()

)
