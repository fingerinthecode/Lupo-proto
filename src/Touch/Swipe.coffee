angular.module('touch').
factory('Swipe', ->
  class Swipe
    @_callbacks: {
      all:   []
      right: []
      left:  []
    }

    @on: (callback, direction='all')->
      @_callbacks[direction].push(callback)

    @right: (callback)->
      @on(callback, 'right')

    @left: (callback)->
      @on(callback, 'left')

  body = window.document.getElementsByTagName('body')[0]
  Hammer(body).on('swipe', ($event)->
    if -90 < $event.angle < 90
      direction = 'right'
    else
      direction = 'left'

    for callback in Swipe._callbacks['all'] ? []
      callback($event)
    for callback in Swipe._callbacks[direction] ? []
      callback($event)
  )

  return Swipe
)
