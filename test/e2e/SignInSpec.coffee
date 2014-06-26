SignIn       = require('./SignIn')
Notification = require('./Notification')

describe('SignIn:', ->
  beforeEach ->
    browser.get('.')

  it("should be redirect to login", ->
    expect(browser.getCurrentUrl()).toMatch('/signin')
  )

  it("should have a login and password input", ->
    expect(SignIn.login.isPresent()).toBeTruthy()
    expect(SignIn.password.isPresent()).toBeTruthy()
  )

  it("should be not possible to signin and should display a notification", ->
    SignIn.signin()
    expect(Notification.count()).toBe(1)
  )
)
