angular.module('session').
controller('SignInCtrl', ($scope, session) ->
  $scope.signInSubmit = ->
    usSpinnerService.spin('main')
    session.signIn($scope.login, $scope.password).then(
      (data) =>
        usSpinnerService.stop('main')
        alert(data)
      (err) =>
        usSpinnerService.stop('main')
        alert(err)
    )
)