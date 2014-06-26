module.exports = class Notification
  @toHave = (nb, type)->
    if type?
      notifs = $$(".notif-overlay.alert-#{type}")
    else
      notifs = $$(".notif-overlay")
    expect(notifs.count()).toBe(nb)

  @toHaveOne = (type)->
    @toHave(1, type)
