`import {Provide}  from 'di.js'`
`import {Assert}   from './../../../src/Utils/Assert'`

assert = jasmine.createSpyObj('assert', [
  'setClassName'
  'setName'
  'isString'
  'error'
  'params'
])

assert.params.and.returnValue(true)

assert.reset = ->
  assert.params.and.returnValue(true)
  assert.setName.calls.reset()
  assert.params.calls.reset()
  assert.error.calls.reset()
  assert.isString.calls.reset()

class AssertMock
  `@Provide(Assert)`
  constructor: ()->
    assert.setClassName.calls.reset()
    return assert

`export {AssertMock, assert}`
