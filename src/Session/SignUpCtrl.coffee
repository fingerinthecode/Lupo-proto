angular.module('session').
controller('SignUpCtrl', ($scope, session, usSpinnerService) ->
  $scope.signUpSubmit = ->
    console.log $scope
    if $scope.password == $scope.password2
      usSpinnerService.spin('main')
      session.signUp($scope.login, $scope.password, $scope.publicName).then(
        (data) =>
          usSpinnerService.stop('main')
          alert(data)
        (err) =>
          alert(err)
          usSpinnerService.stop('main')
      )
    else
      alert("error password")
)

