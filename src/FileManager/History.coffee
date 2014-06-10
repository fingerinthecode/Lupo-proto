angular.module('fileManager').
factory('History', ($rootScope, $stateParams, $state, File, $location)->
  class History
    @_history: []
    @_current: null
    @_goto:    false

    @add: =>
      if not @_goto
        if @_current?
          @_history = @_history[0..@_current]
        @_history.push({
          name:   $state.current.name
          params: angular.copy($stateParams)
        })
        @_current = @_history.length-1
      else
        @_goto = false

    @go: (num)=>
      if not num?
        throw 'History.goto need a parameters to be pass'
        return false

      if @_current+num > @_history.length-1 or
      @_current+num < 0
        throw "History can go to the #{@_current+num} position"
        return false

      @_goto    = true
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
      @go(-1)

    @cantBack: =>
      console.info @_current
      return 0 == @_current

    @forward: =>
      @go(1)

    @cantForward: =>
      return @_history.length-1 == @_current

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

  $rootScope.$on('$stateChangeSuccess', ($event, toState, toParams, fromState, fromParams) ->
    if !toParams.hasOwnProperty('slash') or toParams.slash == '/'
      History.add()
  )

  return History
)
