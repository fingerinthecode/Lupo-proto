angular.module('browser').
factory('Browser', ->
  return class Browser
    @prefixs:  ['webkit', 'Moz', 'ms', 'o', 'khtml']

    @window:   window
    @element:  window.document.documentElement
    @body:     window.document.getElementsByTagName('body')[0]

    @height: ->
      @window.innerHeight   or
      @element.clientHeight or
      @body.clientHeight

    @width: ->
      @window.innerWidth   or
      @element.clientWidth or
      @body.clientWidth

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
