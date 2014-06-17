angular.module('fileManager').
controller('FileManagerCtrl', ($scope, $state, $stateParams, session, fileManager, $document, Clipboard, Selection, History, User, $q, notification, $filter) ->
  unless session.isConnected()
    return





  window.onbeforeunload = ->
    return $filter('translate')('If you reload the page your session will be terminated. Are you sure you want it?')
)
