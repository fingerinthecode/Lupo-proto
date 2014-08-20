`import {Provide}    from 'di.js'`
`import {History}    from './../../../src/FileSystem/History'`

history = {}
history.reset = ->

class HistoryMock
  `@Provide(History)`
  constructor: ()->
    return history

`export {HistoryMock, history}`
