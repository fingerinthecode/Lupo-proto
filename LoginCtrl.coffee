angular.module('lupo-proto').
controller('LoginCtrl', ($scope, session) ->
  $scope.loading = false

  loginSubmit = ->
    $scope.loading = true
    session.login($scope.login, $scope.password).then (data) ->
      $scope.loading = false
      alert("success")
)