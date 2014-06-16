angular.module('session').
controller('SignInCtrl', ($scope, account, notification, usSpinnerService, session, $state) ->

  redirect = session.getFlash('redirect')

  $scope.signInSubmit = () ->
    usSpinnerService.spin('main')
    account.signIn($scope.login, $scope.password).then(
      (data) =>
        console.log "data", data
        usSpinnerService.stop('main')
        if redirect?
          $state.go(redirect.name, redirect.params)
        else
          $state.go('explorer.files')
      (err) =>
        notification.addAlert("Incorrect login/password")
        usSpinnerService.stop('main')
    )
)
