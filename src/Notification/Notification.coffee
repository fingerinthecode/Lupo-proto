angular.module('notification').
factory('notification', ($filter, $interval) ->
  notification = {
    alerts: []
    displayTimeLong:  15000
    displayTimeShort: 5000
    maxAlert: 2

    setDisplayTimeLong: (max) ->
      this.maxAlert = max

    setDisplayTimeLong: (time) ->
      this.displayTimeLong = time * 1000

    setDisplayTimeShort: (time) ->
      this.displayTimeShort = time * 1000

    setAlert: (message, type)->
      this.alerts = []
      this.addAlert(message, type)

    addAlert: (message, type, display = 'short') ->
      add=
        message:  $filter('translate')(message)
        type:     type
        time:     new Date().getTime()
        display:  display

      if this.alerts.length == this.maxAlert
        this.alerts.pop()

      # If the alert is already display delete it
      for alert, i in this.alerts
        if alert.message == add.message
          this.alerts.splice(i,1)
          break

      this.alerts.unshift(add)

    closeAlert: (index) ->
      this.alerts.splice(index, 1)
  }

  $interval( ->
    for alert, i in notification.alerts
      timespend = new Date().getTime() - alert.time
      if timespend >= (if alert.display == 'short' then notification.displayTimeShort else notification.displayTimeLong)
        notification.closeAlert(i)
  , 500)

  return notification
)
