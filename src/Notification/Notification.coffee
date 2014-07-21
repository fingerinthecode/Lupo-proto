angular.module('notification').
factory('Notification', ($filter, $interval) ->
  class Notification
    @alerts: []
    @_displayTimeLong:  15000
    @_displayTimeShort: 5000
    @_maxAlert: 2

    @setDisplayTimeLong: (max)->
      @_maxAlert = max

    @setDisplayTimeLong: (time)->
      @_displayTimeLong = time * 1000

    @setDisplayTimeShort: (time)->
      @_displayTimeShort = time * 1000

    @setAlert: (message, type, display)->
      @alerts = []
      @addAlert(message, type display)

    @addAlert: (message, type = 'warning', display = 'short')->
      add = {
        message:  $filter('translate')(message)
        type:     type
        time:     new Date().getTime()
        display:  display
      }

      if @alerts.length == @_maxAlert
        @alerts.pop()

      # If the alert is already display delete it
      for alert, i in @alerts
        if alert.message == add.message
          @alerts.splice(i,1)
          break

      @alerts.unshift(add)

    @closeAlert: (index)->
      @alerts.splice(index, 1)

  $interval( ->
    for alert, i in Notification.alerts
      timespend = new Date().getTime() - alert.time
      if timespend >= (if alert.display == 'short' then Notification._displayTimeShort else Notification._displayTimeLong)
        console.log i
        Notification.closeAlert(i)
  , 500)

  return Notification
)
