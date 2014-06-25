describe('signup', ->
  it('should greet the named user', ->
    browser.get('http://www.angularjs.org')

    element(by.model('yourName')).sendKeys('Julie')

    expect(greeting.getText()).toEqual('Hello Julie!')
  )
)
