angular.module('lupo-proto').
controller('ContainerCtrl', ($scope, $rootScope, session)->
  $scope.user = session
)
