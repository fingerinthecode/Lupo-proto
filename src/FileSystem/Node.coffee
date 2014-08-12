import {Assert} from './../Utils/'

class Node
  constructor: (doc)->
  @get: (id)->
    assert = new Assert('Node.get')
    assert.params(arguments, ['String'])
    return new Node()

export {Node}
