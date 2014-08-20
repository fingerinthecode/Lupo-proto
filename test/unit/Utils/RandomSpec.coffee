`import {Injector}           from 'di.js'`
`import {AssertMock, assert} from './../Utils/AssertMock'`
`import {random as instance} from './../Utils/RandomMock'`
`import {Random}             from './../../../src/Utils/Random'`

ddescribe "Utils.Random", ->
  random   = null
  injector = null

  beforeEach ->
    Random._instance = null
    injector = new Injector([AssertMock])
    random = injector.get(Random)
    assert.reset()
    instance.reset()


  it "constructor: should receive an instance of Assert", ->
    expect(random._assert).toBe(assert)

  it "constructor: should receive an instance of Assert", ->
    expect(random._assert).toBe(assert)

  it "constructor: should call assert.setClassName with `Random`", ->
    expect(assert.setClassName).toHaveBeenCalledWith('Random')

  it "int: should assert his parameters", ->
    assert.params.and.returnValue(false)

    random.int()
    expect(assert.setName).toHaveBeenCalledWith('int')
    expect(assert.params).toHaveBeenCalledWith(jasmine.any(Object), [['Int', 'Undefined']])

  it "int: should return a random number", ->
    spyOn(Math, 'random').and.returnValue(0.99999999999)
    expect(random.int()).toBe(18)
    expect(random.int(50)).toBe(50)

  it "int: should return a random number", ->
    spyOn(Math, 'random').and.returnValue(0.5)
    expect(random.int()).toBe(9)
    expect(random.int(50)).toBe(25)

  it "string: should assert his parameters", ->
    assert.params.and.returnValue(false)

    random.string()
    expect(assert.setName).toHaveBeenCalledWith('string')
    expect(assert.params).toHaveBeenCalledWith(jasmine.any(Object), [['Int', 'Undefined']])

  it "string: should return a random string", ->
    spyOn(random, 'int').and.returnValue(0)
    expect(random.string()).toBe('aaaaaaaaaaaaaaaaaaaa')
    expect(random.string(25)).toBe('aaaaaaaaaaaaaaaaaaaaaaaaa')

  it "string: should return a random string", ->
    spyOn(random, 'int').and.returnValue(3)
    expect(random.string()).toBe('dddddddddddddddddddd')
    expect(random.string(25)).toBe('ddddddddddddddddddddddddd')

  it "@int: should return a random number", ->
    Random._instance = instance
    expect(Random.int()).toBe(10)
    expect(Random._instance.int).toHaveBeenCalled()
    expect(Random.int(25)).toBe(10)
    expect(Random._instance.int).toHaveBeenCalledWith(25)

  it "@int: should call a singleton instance", ->
    spyOn(Random, 'getInstance').and.callFake ->
      Random._instance = instance
      return instance

    expect(Random.int()).toBe(10)
    expect(Random.getInstance).toHaveBeenCalled()

  it "@string: should return a random string", ->
    Random._instance = instance
    expect(Random.string()).toBe('foo')
    expect(Random._instance.string).toHaveBeenCalled()
    expect(Random.string(25)).toBe('foo')
    expect(Random._instance.string).toHaveBeenCalledWith(25)

  it "@string: should call a singleton instance", ->
    spyOn(Random, 'getInstance').and.callFake ->
      Random._instance = instance
      return instance

    expect(Random.string()).toBe('foo')
    expect(Random.getInstance).toHaveBeenCalled()

  it "@getInstance: should create an instance an save it to _instance", ->
    result = Random.getInstance(injector)
    expect(Random._instance).toBe(result)
    expect(result).toBeAnInstanceOf(Random)
