`import {Injector} from 'di.js'`
`import {Assert}   from './../../../src/Utils/Assert'`

ddescribe "Utils.Assert:", ->
  assert   = null
  injector = null
  types  = {
    undefined: undefined
    null:      null
    boolean:   true
    array:     []
    object:    {}
    function:  -> return 'test'
    string:    ""
    int:       1
    float:     1.1
  }

  beforeEach ->
    injector = new Injector([])
    assert   = injector.get(Assert)

  it "setClassName: have to thow when the name is not a string", ->
    spyOn(assert, 'isString').and.returnValue(false)

    expect(->
      assert.setClassName(true)
    ).toThrow()

  it "setClassName: have to not throw and set the _className property", ->
    spyOn(assert, 'isString').and.returnValue(true)

    expect(->
      assert.setClassName('Test')
    ).not.toThrow()
    expect(assert._className).toBe('Test')

  it "setName: have to thow when the name is not a string", ->
    spyOn(assert, 'isString').and.returnValue(false)

    expect(->
      assert.setName(true)
    ).toThrow()

  it "setName: have to not throw and set the _className property", ->
    spyOn(assert, 'isString').and.returnValue(true)

    expect(->
      assert.setName('test')
    ).not.toThrow()
    expect(assert._methodName).toBe('test')

  it "isUndefined: should check if the value is an undefined", ->
    expect(assert.isUndefined()).toBeTruthy()
    for type in (value for type, value of types when type isnt 'undefined')
      expect(assert.isUndefined(type)).toBeFalsy()

  it "isNull: should check if the value is a null", ->
    expect(assert.isNull(null)).toBeTruthy()
    for type in (value for type, value of types when type isnt 'null')
      expect(assert.isNull(type)).toBeFalsy()

  it "isBoolean: should check if the value is a boolean", ->
    expect(assert.isBoolean(true)).toBeTruthy()
    for type in (value for type, value of types when type isnt 'boolean')
      expect(assert.isBoolean(type)).toBeFalsy()

  it "isString: should check if the value is a string", ->
    expect(assert.isString("")).toBeTruthy()
    for type in (value for type, value of types when type isnt 'string')
      expect(assert.isString(type)).toBeFalsy()

  it "isFunction: should check if the value is a function", ->
    expect(assert.isFunction((->))).toBeTruthy()
    for type in (value for type, value of types when type isnt 'function')
      expect(assert.isFunction(type)).toBeFalsy()

  it "isObject: should check if the value is a object", ->
    expect(assert.isObject({})).toBeTruthy()
    for type in (value for type, value of types when type isnt 'object')
      expect(assert.isObject(type)).toBeFalsy()

  it "isArray: should check if the value is a array", ->
    expect(assert.isArray([])).toBeTruthy()
    for type in (value for type, value of types when type isnt 'array')
      expect(assert.isArray(type)).toBeFalsy()

  it "isInt: should check if the value is a int", ->
    expect(assert.isInt(1)).toBeTruthy()
    for type in (value for type, value of types when type isnt 'int')
      expect(assert.isInt(type)).toBeFalsy()

  it "isFloat: should check if the value is a float", ->
    expect(assert.isFloat(1.1)).toBeTruthy()
    for type in (value for type, value of types when type isnt 'float')
      expect(assert.isFloat(type)).toBeFalsy()

  it "isAny: should check if the value is a float", ->
    for type in (value for type, value of types when type isnt 'null' and type isnt 'undefined')
      expect(assert.isAny(type)).toBeTruthy()
    for type in (value for type, value of types when type is 'null' or type is 'undefined')
      expect(assert.isAny(type)).toBeFalsy()

  it "instanceOf: should check if the value is an instance of", ->
    class Foo
      constructor: (@name)->
    class Bar
      constructor: (@name)->
    bar = new Bar('')

    expect(assert.instanceOf(bar, Bar)).toBeTruthy()
    expect(assert.instanceOf(bar, 'Bar')).toBeTruthy()

    expect(assert.instanceOf(bar, Foo)).toBeFalsy()
    expect(assert.instanceOf(bar, 'Foo')).toBeFalsy()

  it "params: shouldn't throw when type are correct", ->
    spyOn(assert, 'is').and.returnValue(true)
    expect(->
      assert.params({0: 'test'}, [['String', 'Int']])
      assert.params({0: 'test', 1: 'stauienrst'}, ['String', 'Boolean'])
    ).not.toThrow()

  it "params: should throw when type are not correct", ->
    spyOn(assert, 'is').and.returnValue(false)
    spyOn(assert, '_getError').and.returnValue("foo")
    expect(->
      assert.params({0: 'test'}, ['String'])
      assert.params({0: 'test', 1: 'stauienrst'}, ['String', 'Boolean'])
      assert.params({0: 'test'}, ['String', 'Boolean'])
    ).toThrowError("foo")

  it "error: should throw an error saying that he need classname and methodname", ->
    expect(->
      assert.error('a beautiful error :D')
    ).toThrowError("Assert.error() : couldn't display an error if setClassName() and setName() are not call earlier")

  it "error: should throw an beautiful error", ->
    assert._className = 'Test'
    assert._methodName = 'test'

    expect(->
      assert.error('a beautiful error :D')
    ).toThrowError('Test.test() : a beautiful error :D')

  it "is: should return if the value of typeof the second parameters", ->
    spyOn(assert, 'isInt').and.returnValue(true)
    spyOn(assert, 'instanceOf').and.returnValue(true)
    spyOn(assert, 'isBoolean').and.returnValue(false)
    spyOn(assert, 'isAny').and.returnValue(false)
    spyOn(assert, 'isObject').and.returnValue(false)

    expect(assert.is(1, 'Int')).toBeTruthy()
    expect(assert.is(1, ['Test', 'String'])).toBeTruthy()
    expect(assert.is(1, 'Boolean')).toBeFalsy()
    expect(assert.is(1, ['Any', 'Object'])).toBeFalsy()

  it "_getError: should create a beautiful error", ->
    assert._className = 'Test'
    assert._methodName = 'test'

    expect(assert._getError(1, {0: 'test', 1: 'coucou'}, ['Int', 'String'])).toBe("""
      'coucou' is not a String
      Test.test( Int, String )
    """)

    expect(assert._getError(1, {0: 'test', 1: 'coucou'}, ['Int', ['String', 'Folder']])).toBe("""
      'coucou' is not a String or a Folder
      Test.test( Int, String )
      Test.test( Int, Folder )
    """)

    expect(assert._getError(1, {0: 'test', 1: {name: 'test'}}, ['Int', ['String', 'Folder', 'File']])).toBe("""
      object is not a String, a Folder or a File
      Test.test( Int, String )
      Test.test( Int, Folder )
      Test.test( Int, File )
    """)

    expect(assert._getError(1, {0: 'test', 1: true}, ['Int', ['String', 'Folder', 'File']])).toBe("""
      true is not a String, a Folder or a File
      Test.test( Int, String )
      Test.test( Int, Folder )
      Test.test( Int, File )
    """)
