angular.module('fileManager').
factory('History', ($rootScope, $stateParams, $state, File)->
  class History
    @_history: []
    @_current: null

    @add: =>
      current = @_history[@_current]
      if current? and
      $stateParams == current.params and
      current.name == $state.current.name
        return false

      if @_current?
        @_history = @_history[0..@_current]
      @_history.push({
        name:   $state.current.name
        params: angular.copy($stateParams)
      })
      @_current = @_history.length-1

    @goto: (num)=>
      if not num?
        throw 'History.goto need a parameters to be pass'
        return false

      if @_current+num > @_history.length-1 or
      @_current+num < 0
        throw "History can go to the #{@_current+num} position"

      @_current = @_current + num
      goto      = @_history[@_current]
      $state.transitionTo(
        goto.name
        goto.params
        {
          location: true
        }
      )

    @back: =>
      @goto(-1)

    @forward: =>
      @goto(1)

    @parent: =>
      id = $stateParams.path
      File.getFile(id).then(
        (file)=>
          $state.go('.', {
            path: file.metadata.parent_id
          }, {
            location: true
          })
        ,(err)=>
          console.log err
      )


  $rootScope.$on('$stateChangeSuccess', ->
    History.add()
    console.log $state
  )

  return History
)
