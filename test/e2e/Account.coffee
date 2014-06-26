Random = require('./Random')

module.exports = class Account
  @_username:   Random.string(30)
  @_password:   Random.string(30)
  @_publicName: Random.string(30)

  @signin: ->
    browser.get('#/sigin')
    $login    = $('#login')
    $password = $('#password')
    $button   = $('form button')

    expect($login.isPresent()).toBeTruthy()
    expect($password.isPresent()).toBeTruthy()
    expect($button.isPresent()).toBeTruthy()

    if $login.isPresent() and
    $password.isPresent() and
    $button.isPresent()
      $login.sendKeys(@_username)
      $password.sendKeys(@_password)
      $button.click()

  @signup: (username=@_username, password=@_password, passconf=@_password, name=@_publicName)->
    browser.get('#/signup')
    $login    = $('#login')
    $password = $('#password')
    $passconf = $('#password2')
    $button   = $('#password2')
    $name     = $('#publicName')

    expect($login.isPresent()).toBeTruthy()
    expect($password.isPresent()).toBeTruthy()
    expect($passconf.isPresent()).toBeTruthy()
    expect($name.isPresent()).toBeTruthy()
    expect($button.isPresent()).toBeTruthy()

    if $login.isPresent() and
    $password.isPresent() and
    $passconf.isPresent() and
    $button.isPresent()
      $login.sendKeys(username)
      $password.sendKeys(password)
      $passconf.sendKeys(passconf)
      $name.sendKeys(name)
      $button.click()

  @signupWithWrongPassword: ->
    @signup(null, 'straun')

