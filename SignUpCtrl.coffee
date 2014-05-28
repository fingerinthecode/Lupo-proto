angular.module('lupo-proto').
controller('SignUpCtrl', ($scope, session) ->
  $scope.loading = false

  signUpSubmit = ->
    if $scope.password == $scope.password2
      $scope.loading = true
      session.signup($scope.login, $scope.password, $scope.publicName).then (data) ->
        $scope.loading = false
        alert("success")
    else
      alert("error password")
)


