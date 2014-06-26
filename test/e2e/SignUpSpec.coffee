SignUp      = require('./SignUp')
Notfication = require('./Notification')

describe("SignUp:", ->
  beforeEach ->
    browser.get('.')

  it("should have fields", ->
    expect(SignUp.login.isPresent()).toBeTruthy()
    expect(SignUp.password.isPresent()).toBeTruthy()
    expect(SignUp.passconf.isPresent()).toBeTruthy()
    expect(SignUp.name.isPresent()).toBeTruthy()
  )

  it("should display a notification if the two password are not equals", ->
    SignUp.signupWithWrongPassword()
    expect(Notification.get().count()).toBe(1)
  )
)
