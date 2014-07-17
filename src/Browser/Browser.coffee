angular.module('browser').
factory('Browser', ->
  return class Browser
    @prefixs:  ['webkit', 'Moz', 'ms', 'o', 'khtml']

    @window:   window
    @element:  window.document.documentElement
    @body:     window.document.getElementsByTagName('body')[0]

    @_height: ->
      @window.innerHeight   or
      @element.clientHeight or
      @body.clientHeight

    @height: ->
      if window.screen? and window.screen.availHeight?
        return window.screen.availHeight
      else
        return @_height()

    @_width: ->
      @window.innerWidth   or
      @element.clientWidth or
      @body.clientWidth

    @width: ->
      if window.screen? and window.screen.availWidth?
        return window.screen.availWidth
      else
        return @_width()

    @haveTransform: ->
      return @testCSSProp('transform')

    @title: (string)->
      return string[0].toUpperCase() + string[1..].toLowerCase()

    @testCSSProp: (name)->
      if @body.style[name]?
        return true

      name = @title(name)

      if @body.style[name]?
        return true

      for prefix in @prefixs
        if @body.style["#{prefix}#{name}"]?
          return true
      return false
)
