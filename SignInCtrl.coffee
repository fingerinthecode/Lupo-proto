angular.module('lupo-proto').
controller('SignInCtrl', ($scope, session) ->
  $scope.loading = false

  signInSubmit = ->
    $scope.loading = true
    session.signIn($scope.login, $scope.password).then
      (data) =>
        $scope.loading = false
        alert(data)
      (err) =>
        alert(err)
)