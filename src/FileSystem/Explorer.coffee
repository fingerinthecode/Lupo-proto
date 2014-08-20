`import {Inject}      from 'di.js'`
`import {Selection}   from './Selection'`
`import {RootFolder}  from './RootFolder'`
`import {Actions}     from './Actions'`
`import {History}     from './History'`

class Explorer
  _selection: null
  _folder: null
  _actions: null
  _history: null

  `@Inject(Selection, RootFolder, Actions, History)`
  constructor: (
    @_selection
    @_folder
    @_actions
    @_history
  ) ->

`export {Explorer}`
