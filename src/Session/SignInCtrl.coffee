angular.module('session').
controller('SignInCtrl', ($scope, account, notification, usSpinnerService, session, $state) ->

  flash = session.getFlash('redirect')

  $scope.signInSubmit = () ->
    usSpinnerService.spin('main')
    account.signIn($scope.login, $scope.password).then(
      (data) =>
        console.log "data", data
        usSpinnerService.stop('main')
        if flash?
          $state.go(flash[0], flash[1])
        else
          $state.go('files')
      (err) =>
        notification.addAlert("Incorrect login/password")
        usSpinnerService.stop('main')
    )
)
