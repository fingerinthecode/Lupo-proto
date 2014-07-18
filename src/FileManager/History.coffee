angular.module('fileManager').
factory('History', ($rootScope, $stateParams, $state, File, $location, session)->
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
        throw 'History.goto need a parameter'
        return false

      if @_current+num > @_history.length-1 or
      @_current+num < 0
        throw "History can't go to the #{@_current+num} position"
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
      return 0 == @_current

    @forward: =>
      @go(1)

    @cantForward: =>
      return @_history.length-1 == @_current

    @redirect: (id)->
      $state.go('.', {
        path: id
      }, {
        location: true
      })

    @parent: =>
      id = $stateParams.path
      if id == "shares"
        @redirect('')
      else
        File.get(id).then(
          (file)=>
            id = file.metadata.parentId
            if id == session.getRootFolderId()
              @redirect('')
            else
              @redirect(id)
          ,(err)=>
            console.error err
        )

  $rootScope.$on('$stateChangeSuccess', ($event, toState, toParams, fromState, fromParams) ->
    if !toParams.hasOwnProperty('slash') or toParams.slash == '/'
      History.add()
  )

  return History
)
