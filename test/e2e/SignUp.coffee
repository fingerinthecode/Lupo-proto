Account = require('./Account')
module.exports = class SignUp
  @login:    $('#login')
  @password: $('#password')
  @passconf: $('#password2')
  @button:   $('#password2')
  @name:     $('#publicName')

  @signup: (
    username = Account.username,
    password = Account.password,
    passconf = Account.password,
    name     = Account.publicName,
  )->
    @login.sendKeys(username)
    @password.sendKeys(password)
    @passconf.sendKeys(passconf)
    @name.sendKeys(name)
    @button.click()

  @signupWithWrongPassword: ->
    @signup(null, 'straun')
