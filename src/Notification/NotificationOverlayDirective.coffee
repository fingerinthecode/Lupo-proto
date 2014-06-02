angular.module('notification').
directive('notificationOverlay', (notification) ->
  return {
    restrict: 'E'
    template: '<div ng-repeat="notif in notifs.alerts" class="notif-overlay alert alert-{{ notif.type || \'warning\' }}">'+
                '<button class="close" ng-click="close($index)">&times;</button>'+
                '{{ notif.message }}'+
              '</div>'
    link:  (scope, element, attrs) ->
      element.css({
        "position": "fixed"
        "top": "60px"
        "right": "40px"
        "zIndex": "9999"
        "width": "300px"
      })
      scope.notifs = notification

      scope.close = ($index) ->
        notification.closeAlert($index)
  }
)
