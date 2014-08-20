`import {Injector}                  from 'di.js'`
`import {AssertMock, assert}        from './../Utils/AssertMock'`
`import {MapMock, map, mapiterator} from './../MapMock'`
`import {Selection}                 from './../../../src/FileSystem/Selection'`

ddescribe "FileSystem.Selection:", ->
  selection = null
  injector  = null

  beforeEach ->
    injector = new Injector([AssertMock, MapMock])
    selection = injector.get(Selection)
    assert.reset()
    map.reset()

  it "constructor: should receive an instance of Assert", ->
    expect(selection._assert).toBe(assert)

  it "constructor: should receive an instance of Map", ->
    expect(selection._selectedNode).toBe(map)

  it "constructor: should call assert.setClassName with `Selection`", ->
    expect(assert.setClassName).toHaveBeenCalledWith('Selection')

  it "clear: should assert his parameters", ->
    assert.params.and.returnValue(false)

    selection.clear()
    expect(assert.setName).toHaveBeenCalledWith('clear')
    expect(assert.params).toHaveBeenCalledWith(jasmine.any(Object), [])

  it "clear: should clear the selection", ->
    selection.clear()
    expect(map.clear).toHaveBeenCalled()

  it "get: should assert his parameters", ->
    assert.params.and.returnValue(false)

    selection.get()
    expect(assert.setName).toHaveBeenCalledWith('get')
    expect(assert.params).toHaveBeenCalledWith(jasmine.any(Object), ['Undefined', 'String'])

  it "get: should return the selection", ->
    assert.isString.and.returnValue(false)
    # Return the Map
    expect(selection.get()).toBe(map)

  it "forEach: should assert his parameters", ->
    assert.params.and.returnValue(false)

    selection.forEach()
    expect(assert.setName).toHaveBeenCalledWith('forEach')
    expect(assert.params).toHaveBeenCalledWith(jasmine.any(Object), ['Function'])

  it "forEach: should callback for each node", ->
    func = ()->
      return 'foo'
    selection.forEach(func)
    expect(map.forEach).toHaveBeenCalledWith(func)

  it "getFirst: should assert his parameters", ->
    assert.params.and.returnValue(false)

    selection.getFirst()
    expect(assert.setName).toHaveBeenCalledWith('getFirst')
    expect(assert.params).toHaveBeenCalledWith(jasmine.any(Object), [])

  it "getFirst: should return only one element", ->
    expect(selection.getFirst()).toBe('foo')
    expect(map.values).toHaveBeenCalled()
    expect(mapiterator.next).toHaveBeenCalled()

  it "set: should assert his parameters", ->
    assert.params.and.returnValue(false)

    selection.set()
    expect(assert.setName).toHaveBeenCalledWith('set')
    expect(assert.params).toHaveBeenCalledWith(jasmine.any(Object), ['Node'])

  it "set: should set the node in the selection", ->
    node = {'_id': 'foo'}
    selection.set(node)
    expect(map.set).toHaveBeenCalledWith(node._id, node)

  it "has: should assert his parameters", ->
    assert.params.and.returnValue(false)

    selection.has()
    expect(assert.setName).toHaveBeenCalledWith('has')
    expect(assert.params).toHaveBeenCalledWith(jasmine.any(Object), [['Node', 'String']])

  it "has: should check if the map has the key, with string", ->
    assert.isString.and.returnValue(true)
    selection.has('foo')
    expect(map.has).toHaveBeenCalledWith('foo')

  it "has: should return true when the element is in the map, width node", ->
    assert.isString.and.returnValue(false)
    selection.has({'_id': 'foo'})
    expect(map.has).toHaveBeenCalledWith('foo')

  it "delete: should assert his parameters", ->
    assert.params.and.returnValue(false)

    selection.delete()
    expect(assert.setName).toHaveBeenCalledWith('delete')
    expect(assert.params).toHaveBeenCalledWith(jasmine.any(Object), [['Node', 'String']])

  it "delete: should delete the key from the map, with string", ->
    assert.isString.and.returnValue(true)
    map.delete.and.returnValue(true)

    selection.delete('foo')
    expect(map.delete).toHaveBeenCalledWith('foo')

  it "delete: should delete the key from the map, with node", ->
    assert.isString.and.returnValue(false)
    map.delete.and.returnValue(true)

    selection.delete({'_id': 'foo'})
    expect(map.delete).toHaveBeenCalledWith('foo')

  it "delete: should throw if the element doesn't exist", ->
    assert.isString.and.returnValue(true)
    map.delete.and.returnValue(false)
    selection.delete()
    expect(assert.error).toHaveBeenCalledWith("Node is not in the selection")

  it "isEmpty: should assert his parameters", ->
    assert.params.and.returnValue(false)

    selection.isEmpty()
    expect(assert.setName).toHaveBeenCalledWith('isEmpty')
    expect(assert.params).toHaveBeenCalledWith(jasmine.any(Object), [])

  it "isEmpty: should check if the selection is empty", ->
    map.size = 0
    expect(selection.isEmpty()).toBeTruthy()
    map.size = 1
    expect(selection.isEmpty()).toBeFalsy()

  it "hasOnlyOneFile: should assert his parameters", ->
    assert.params.and.returnValue(false)

    selection.hasOnlyOneFile()
    expect(assert.setName).toHaveBeenCalledWith('hasOnlyOneFile')
    expect(assert.params).toHaveBeenCalledWith(jasmine.any(Object), [])

  it "hasOnlyOneFile: should check if the selection is empty", ->
    map.size = 0
    expect(selection.hasOnlyOneFile()).toBeFalsy()
    map.size = 1
    expect(selection.hasOnlyOneFile()).toBeTruthy()
    map.size = 2
    expect(selection.hasOnlyOneFile()).toBeFalsy()
    map.size = 3
    expect(selection.hasOnlyOneFile()).toBeFalsy()

  it "hasMultipleFile: should assert his parameters", ->
    assert.params.and.returnValue(false)

    selection.hasMultipleFile()
    expect(assert.setName).toHaveBeenCalledWith('hasMultipleFile')
    expect(assert.params).toHaveBeenCalledWith(jasmine.any(Object), [])

  it "hasMultipleFile: should check if the selection is empty", ->
    map.size = 0
    expect(selection.hasMultipleFile()).toBeFalsy()
    map.size = 1
    expect(selection.hasMultipleFile()).toBeFalsy()
    map.size = 2
    expect(selection.hasMultipleFile()).toBeTruthy()
    map.size = 3
    expect(selection.hasMultipleFile()).toBeTruthy()
