angular.module('fileManager').
filter('ellipsis', ->
  return (text, limit, end = '…')->
    if text.length < limit
      return text
    else
      return text.substr(0, limit) + end
)
