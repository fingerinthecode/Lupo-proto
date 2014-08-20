`import {Injector}                   from 'di.js'`
`import {AssertMock, assert}         from './../Utils/AssertMock'`
`import {SelectionMock, selection}   from './../FileSystem/SelectionMock'`
`import {RootFolderMock, rootfolder} from './../FileSystem/RootFolderMock'`
`import {ActionsMock, actions}       from './../FileSystem/ActionsMock'`
`import {HistoryMock, history}       from './../FileSystem/HistoryMock'`
`import {Explorer}                   from './../../../src/FileSystem/Explorer'`

ddescribe "FileSystem.Explorer:", ->
  explorer = null
  injector = null

  beforeEach ->
    injector = new Injector([
      SelectionMock
      RootFolderMock
      ActionsMock
      HistoryMock
    ])
    explorer = injector.get(Explorer)

  it "constructor: should inject an instance of `Selection`", ->
    expect(explorer._selection).toBe(selection)

  it "constructor: should inject an instance of `RootFolder`", ->
    expect(explorer._folder).toBe(rootfolder)

  it "constructor: should inject an instance of `Actions`", ->
    expect(explorer._actions).toBe(actions)

  it "constructor: should inject an instance of `History`", ->
    expect(explorer._history).toBe(history)


