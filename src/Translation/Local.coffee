angular.module('translation').
factory('Local', ($http, $location)->
  return {
    get: (lang)=>
      url = $location.absUrl()
      url = url.split('#')[0]
      return $http.get("#{url}get/local:#{lang}")
  }
)
