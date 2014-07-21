angular.module('browser').
factory('Shortcut', ($document)->
  class Shortcut
    @shortcuts: {}
    @_codes: {
      27:'esc', 8:'backspace', 9:'tab', 93:'menu', 13:'enter', 46:'del',
      # Mouvement keys
      37:'left', 38:'up', 39:'right', 40:'down',
      # Function Keys
      112:'f1', 113:'f2', 114:'f3', 115:'f4', 116:'f5', 117:'f6', 118:'f7', 119:'f8', 120:'f9', 121:'f10', 122:'f11', 123:'f12',
      32:'space',
      # UpperCase
      65:'A', 66:'B', 67:'C', 68:'D', 69:'E', 70:'F', 71:'G', 72:'H', 73:'I', 74:'J', 75:'K', 76:'L', 77:'M', 78:'N',
      79:'O', 80:'P', 81:'Q', 82:'R', 83:'S', 84:'T', 85:'U', 86:'V', 87:'W', 88:'X', 89:'Y', 90:'Z',
      # LowerCase
      97:'a', 98:'b', 99:'c', 100:'d', 101:'e', 102:'f', 103:'g', 104:'h', 105:'i', 106:'j', 107:'k', 108:'l', 109:'m', 110:'n',
      111:'o', 112:'p', 113:'q', 114:'r', 115:'s', 116:'t', 117:'u', 118:'v', 119:'w', 120:'x', 121:'y', 122:'z'
    }

    @_normalize: (keys)->
      keys = keys.toLowerCase()
      keys = keys.replace(/\s/gi, '')
      keys = keys.replace('control', 'ctrl')
      keys = keys.replace('super', 'meta')
      keys = keys.replace('command', 'meta')
      keys = keys.replace('escape', 'esc')
      keys = keys.split('+')
      keys = keys.sort()
      keys = keys.join('+')
      return keys

    @keys: ($event)->
      keys = []
      if $event.altKey
        keys.push('alt')
      if $event.ctrlKey
        keys.push('ctrl')
      if $event.shiftKey
        keys.push('shift')
      if $event.metaKey
        keys.push('meta')

      keys.push(@_codes[$event.keyCode] ? '')
      keys = keys.join('+')
      return @_normalize(keys)

    @on: (keys, callback)->
      keys = @_normalize(keys)

      @shortcuts[keys] ?= []
      @shortcuts[keys].push(callback)

  $document.on('keydown', ($event)->
    keys = Shortcut.keys($event)
    console.info keys, $event
    for shortcut in Shortcut.shortcuts[keys] ? []
      shortcut()
  )
  return Shortcut
)
