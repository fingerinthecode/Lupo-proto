module.exports = class Notification
  @toHave = (nb, type='warning')->
    notifs = $$(".notif-overlay.alert-#{type}")
    expect(notifs.count()).toBe(nb)

  @toHaveOne = (type)->
    @toHave(1, type)
