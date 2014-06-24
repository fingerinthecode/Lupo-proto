angular.module('filters').
filter('ellipsis', ->
  return (text, limit, end = '…')->
    if text?
      if text.length < limit+1
        return text
      else
        return text.substr(0, limit) + end
)
