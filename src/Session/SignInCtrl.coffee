angular.module('session').
controller('SignInCtrl', ($scope, account, usSpinnerService) ->
  $scope.signInSubmit = ->
    usSpinnerService.spin('main')
    account.signIn($scope.login, $scope.password).then(
      (data) =>
        usSpinnerService.stop('main')
        alert(data)
      (err) =>
        usSpinnerService.stop('main')
        alert(err)
    )
)