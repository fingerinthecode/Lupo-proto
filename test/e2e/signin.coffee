Account = require('./Account')
module.exports = class SignIn
  @login:    $('#login')
  @password: $('#password')
  @button:   $('#password')

  @signin: ->
    @login.sendKeys(Account.username)
    @password.sendKeys(Account.password)
    @button.click()
