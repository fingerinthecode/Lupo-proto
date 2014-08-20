`import {Provide}    from 'di.js'`
`import {Actions}    from './../../../src/FileSystem/Actions'`

actions = {}
actions.reset = ->

class ActionsMock
  `@Provide(Actions)`
  constructor: ()->
    return actions

`export {ActionsMock, actions}`
