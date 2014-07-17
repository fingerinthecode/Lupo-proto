angular.module('notification').
directive('notificationOverlay', (notification) ->
  return {
    restrict: 'E'
    replace:  true
    template: """
              <div class="notification-overlay">
                <div ng-repeat="notif in notifs.alerts" class="alert alert-{{ notif.type || \'warning\' }}">
                  <button class="close" ng-click="close($index)">&times;</button>
                  {{ notif.message }}
                </div>
              </div>
              """
    link:  (scope, element, attrs) ->
      scope.notifs = notification

      scope.close = ($index) ->
        notification.closeAlert($index)
  }
)
