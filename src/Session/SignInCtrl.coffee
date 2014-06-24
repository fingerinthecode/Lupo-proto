angular.module('session').
controller('SignInCtrl', ($scope, account, notification, usSpinnerService, session, $state) ->

  $scope.signInSubmit = () ->
    usSpinnerService.spin('main')
    account.signIn($scope.login, $scope.password).then(
      (data) =>
        console.log "data", data
        usSpinnerService.stop('main')
        $state.go('explorer.files', {
          path: ''
        })
      (err) =>
        notification.addAlert("Incorrect login/password")
        usSpinnerService.stop('main')
    )
)
