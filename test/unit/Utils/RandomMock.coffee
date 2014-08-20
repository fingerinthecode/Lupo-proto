`import {Provide}  from 'di.js'`
`import {Random}   from './../../../src/Utils/Random'`

random = jasmine.createSpyObj('random', [
  'int'
  'string'
])

random.reset = ->
  random.int.and.returnValue(10)
  random.string.and.returnValue('foo')
  random.int.calls.reset()
  random.string.calls.reset()

class RandomMock
  `@Provide(Random)`
  constructor: ()->
    return random

`export {RandomMock, random}`
