angular.module('lupo-proto').
factory 'DeferredQueue', ($q) ->
  class DeferredQueue
    constructor: (@size) ->
      @_deferredList = []
      for i in [0..@size-1]
        def = $q.defer()
        def.resolve()
        @_deferredList.push def.promise
        @_idx = 0  #round robin index

    enqueue: (fun) ->
      @_deferredList[@_idx].then(fun, fun)
      @_idx++
      if @_idx >= @size
        @_idx = 0