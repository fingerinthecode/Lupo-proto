Account      = require('./Account')
Notification = require('./Notification')

describe('signup', ->
  it("should be redirect to login", ->
    browser.get('.')
    expect(browser.getCurrentUrl()).toMatch('/signin')
  )

  it("should be not possible to signin and should display a notification", ->
    Account.signin()
    Notification.toHaveOne()
  )

  it("shouldn't be able to signup with two different password", ->
    Account.signupWithWrongPassword()
    Notification.toHaveOne('danger')
  )
)
