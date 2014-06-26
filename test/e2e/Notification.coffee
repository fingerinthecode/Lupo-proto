module.exports = class Notification
  @get: (nb, type)->
    if type?
      return $$(".notif-overlay.alert-#{type}")
    else
      return $$(".notif-overlay")

  @count: ->
    return @get().count()
