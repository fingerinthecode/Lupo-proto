module.exports = class Random
  @string: (number=10)->
    text  = ""
    chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGIJKLMNOPQRSTUVWXYZ'

    for i in [1..number]
      random  = Math.floor(Math.random()*chars.length)
      text   += chars.charAt(random)

    return text


