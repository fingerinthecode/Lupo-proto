`import {Inject}   from 'di.js'`
`import {Injector} from 'di.js'`
`import {Assert}   from './../Utils/Assert'`

class Random
  @_instance: null
  _assert: null

  ###
  # Random( assert : Assert ) : Random
  # Create a random generator
  ###
  `@Inject(Assert)`
  constructor: (@_assert)->
    @_assert.setClassName('Random')

  ###
  # getInstance() : Random
  # return an singleton instance of Random
  ###
  @getInstance: (injector)->
    if not @_instance?
      injector ?= new Injector()
      instance = injector.get(Random)
      @_instance = instance
    return @_instance

  ###
  # int() : Int
  # int( max : Int ) : Int
  # return an random int
  ###
  @int: (max)->
    @getInstance()
    return @_instance.int(max)

  ###
  # string() : String
  # string( length : Int ) : String
  # return an random string
  ###
  @string: (length)->
    @getInstance()
    return @_instance.string(length)

  ###
  # int() : Int
  # int( max : Int ) : Int
  # return an random int
  ###
  int: (max=18)->
    @_assert.setName('int')
    if @_assert.params(arguments, [['Int', 'Undefined']])
      return Math.floor(Math.random()*(max+1))

  ###
  # string() : String
  # int( length : Int ) : String
  # return a random string
  ###
  string: (length=20)->
    @_assert.setName('string')
    if @_assert.params(arguments, [['Int', 'Undefined']])
      chars  = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
      string = ""
      for i in [1..length]
        string += chars.charAt(@int(chars.length-1))
      return string

`export { Random }`
