angular.module('session').
controller('SignUpCtrl', ($scope, account, usSpinnerService, $state, notification) ->
  $scope.signUpSubmit = ->
    console.log $scope
    if $scope.password == $scope.password2
      usSpinnerService.spin('main')
      account.signUp($scope.login, $scope.password, $scope.publicName).then(
        (data) =>
          usSpinnerService.stop('main')
          $state.go('explorer.files')
        (err) =>
          usSpinnerService.stop('main')
          notification.addAlert("The login is already taken!", 'danger')
      )
    else
      notification.addAlert("Password don't match!", 'danger')

)
