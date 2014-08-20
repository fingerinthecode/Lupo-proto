`import {Provide} from 'di.js'`

mapiterator = jasmine.createSpyObj('mapiterator', [
  'next'
])
mapiterator.next.and.returnValue({value: 'foo', done: false})

map = jasmine.createSpyObj('map', [
  'set'
  'get'
  'has'
  'clear'
  'delete'
  'forEach'
  'values'
])

map.reset = ()->
  map.set.calls.reset()
  map.get.calls.reset()
  map.has.calls.reset()
  map.clear.calls.reset()
  map.delete.calls.reset()
  map.values.calls.reset()
  map.values.and.returnValue(mapiterator)

class MapMock
  `@Provide(Map)`
  constructor: ()->
    return map

`export {MapMock, map, mapiterator}`
