angular.module('fileManager').
controller('ExplorerCtrl', ($scope, $state, session, fileManager, Clipboard, Selection, History, $filter, $document, Watcher) ->
  unless session.isConnected()
    return

  Watcher.start()
  $scope.$on('Changes', ($event, id)->
  )

  #-------------Ctrl + Shortcut------------
  $document.on('keypress', ($event)->
    if Selection.hasFile('shares')
      return false
    if $event.ctrlKey or $event.metaKey
      switch $event.charCode
        when 120 then Clipboard.cut()    # X
        # when 99  then Clipboard.copy()   # C
        when 118 then Clipboard.paste()  # V
  )

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

  window.onbeforeunload = ->
    return $filter('translate')('ALERT_RELOAD')
)
