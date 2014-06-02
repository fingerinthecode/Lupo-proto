angular.module('session').
controller('SignInCtrl', ($scope, account, usSpinnerService, session, $state) ->

  flash = session.getFlash('redirect')

  $scope.signInSubmit = ->
    usSpinnerService.spin('main')
    account.signIn($scope.login, $scope.password).then(
      (data) =>
        usSpinnerService.stop('main')
        if flash?
          $state.go(flash[0], flash[1])
        else
          $state.go('files')
      (err) =>
        usSpinnerService.stop('main')
    )
)
