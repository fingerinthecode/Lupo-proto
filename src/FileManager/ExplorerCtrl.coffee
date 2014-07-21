angular.module('fileManager').
controller('ExplorerCtrl', ($scope, $state, session, fileManager, Selection, History, $filter) ->
  unless session.isConnected()
    return

  $scope.History     = History
  $scope.Selection   = Selection
  $scope.fileManager = fileManager

  $scope.isRoot = ->
    path = $state.params.path ? ''
    return path is ''

  # -------------Display Mode--------
  $scope.toList = ->
    session.set('displayThumb', false)

  $scope.toThumb = ->
    session.set('displayThumb', true)

  # window.onbeforeunload = ->
  #   return $filter('translate')('ALERT_RELOAD')
)
