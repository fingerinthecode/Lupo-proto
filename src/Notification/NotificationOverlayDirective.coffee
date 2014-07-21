angular.module('notification').
directive('notificationOverlay', (Notification) ->
  return {
    restrict: 'E'
    replace:  true
    template: """
              <div class="notification-overlay">
                <div ng-repeat="notif in Notification.alerts" class="alert alert-{{ notif.type }}">
                  <button class="close" ng-click="Notification.closeAlert($index)">&times;</button>
                  <div class="alert-content">{{ notif.message }}</div>
                </div>
              </div>
              """
    link:  (scope, element, attrs) ->
      scope.Notification = Notification
  }
)
