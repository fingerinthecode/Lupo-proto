angular.module('fileManager').
factory('File', ->
  return {
    display: true
    setThumb: =>
      @display = true

    setList: =>
      @display = false

  }
)
