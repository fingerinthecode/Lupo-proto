`import {Provide}    from 'di.js'`
`import {RootFolder} from './../../../src/FileSystem/RootFolder'`

rootfolder = {}
rootfolder.reset = ->

class RootFolderMock
  `@Provide(RootFolder)`
  constructor: ()->
    return rootfolder

`export {RootFolderMock, rootfolder}`
