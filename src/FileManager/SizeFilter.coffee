angular.module('fileManager').
filter('size', ->
  return (size)->
    unity = 'B'

    if size > 1000
      size /= 1000
      unity = 'KB'
      if size > 1000
        size /= 1000
        unity = 'MB'
        if size > 1000
          size /= 1000
          unity = 'GB'

    if size != 0
      size = Math.round(size*10)/10

    return  "#{size}#{unity}"
)
