`import {Inject} from 'di.js'`
`import {Assert} from './../Utils/Assert'`

class Selection
  _assert: null
  _selectedNode: null

  ###
  # Selection( assert : Assert ) : Selection
  # Create a selection
  ###
  `@Inject(Assert, Map)`
  constructor: (@_assert, @_selectedNode)->
    @_assert.setClassName('Selection')

  ###
  # clear()
  # Clear the selection
  ###
  clear: ()->
    @_assert.setName('clear')
    if @_assert.params(arguments, [])
      @_selectedNode.clear()

  ###
  # get() : Object
  # Return the all selection
  ###
  get: (id)->
    @_assert.setName('get')
    if @_assert.params(arguments, ['Undefined', 'String'])
      return @_selectedNode


  ###
  # forEach( callback : Function )
  # Callback for each node in the selection
  ###
  forEach: (callback)->
    @_assert.setName('forEach')
    if @_assert.params(arguments, ['Function'])
      @_selectedNode.forEach(callback)

  ###
  # getFirst() : Node
  # Return the first node of the selection
  ###
  getFirst: ()->
    @_assert.setName('getFirst')
    if @_assert.params(arguments, [])
      return @_selectedNode.values().next().value

  ###
  # set( node : Node )
  # Add/Set the node in the selection
  ###
  set: (node)->
    @_assert.setName('set')
    if @_assert.params(arguments, ['Node']) and not @has(node)
      @_selectedNode.set(node._id, node)

  ###
  # has( node : Node )   : Boolean
  # has( node : String ) : Boolean
  # Check if the node is already in the selection,
  # you can check with the _id too
  ###
  has: (node)->
    @_assert.setName('has')
    if @_assert.params(arguments, [['Node', 'String']])
      if not @_assert.isString(node)
        node = node._id
      return @_selectedNode.has(node)

  ###
  # delete( node : Node )
  # delete( node : String )
  # Should remove the node from the selection if it exist
  # This will thow an error if the node is not in the selection
  ###
  delete: (node)->
    @_assert.setName('delete')
    if @_assert.params(arguments, [['Node', 'String']])
      if not @_assert.isString(node)
        node = node._id
      if not @_selectedNode.delete(node)
        @_assert.error("Node is not in the selection")

  ###
  # isEmpty() : Boolean
  # Return true when the selection is empty
  ###
  isEmpty: ()->
    @_assert.setName('isEmpty')
    if @_assert.params(arguments, [])
      return @_selectedNode.size == 0

  ###
  # hasOnlyOneFile() : Boolean
  # Return true when the selection has only one file
  ###
  hasOnlyOneFile: ()->
    @_assert.setName('hasOnlyOneFile')
    if @_assert.params(arguments, [])
      return @_selectedNode.size == 1

  ###
  # hasMultipleFile() : Boolean
  # Return true when the selection has more than one file
  ###
  hasMultipleFile: ()->
    @_assert.setName('hasMultipleFile')
    if @_assert.params(arguments, [])
      return @_selectedNode.size > 1

`export {Selection}`
