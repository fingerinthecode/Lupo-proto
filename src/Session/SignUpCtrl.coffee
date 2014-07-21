angular.module('session').
controller('SignUpCtrl', ($scope, account, usSpinnerService, $state, Notification) ->
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
          Notification.addAlert("The login is already taken!", 'danger')
      )
    else
      Notification.addAlert("Password don't match!", 'danger')

)
