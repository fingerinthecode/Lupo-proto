angular.module('lupo-proto').
factory 'db', ($http) ->
  class DB
    constructor: (@dbUrl) ->

    _encodeOptions: (options) ->
      buf = [];
      if options? and angular.isObject(options)
        for name in options
          value = options[name]
          if name in ["key", "startkey", "endkey"]
            value = toJSON(value)
          buf.push(encodeURIComponent(name) + "=" + encodeURIComponent(value))
      return if buf.length then "?" + buf.join("&") else ""

    get: (_id) ->
      $http.get(@dbUrl + _id).then (result) =>
        return result.data

    put: (doc) ->
      $http.put(@dbUrl + doc._id, doc, {
        'Content-Type': "application/json"
      }).then (result) =>
        return result.data

    post: (doc) ->
      $http.post(@dbUrl, doc, {
        'Content-Type': "application/json"
      }).then (result) =>
        return result.data

    query: (fun, options) ->
      s = fun.split('/')
      ddoc = s[0]
      view = s[1]
      $http.get(@dbUrl + "_design/#{ddoc}/_view/#{view}" + @_encodeOptions(options))
      .then (result) =>
        return result.data
