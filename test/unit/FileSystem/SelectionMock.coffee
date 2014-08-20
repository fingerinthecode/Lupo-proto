`import {Provide}   from 'di.js'`
`import {Selection} from './../../../src/FileSystem/Selection'`

selects = {
  'foo': {
    '_id': 'foo'
  }
  'bar': {
    '_id': 'bar'
  }
}

selection = jasmine.createSpyObj('selection', [
  'get'
  'clear'
])

selection.get.and.returnValue(selects)

selection.reset = ->
  selection.get.calls.reset()
  selection.clear.calls.reset()

class SelectionMock
  `@Provide(Selection)`
  constructor: ()->
    return selection

`export {SelectionMock, selection, selects}`
