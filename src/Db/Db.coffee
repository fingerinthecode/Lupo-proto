angular.module('lupo-proto').
factory 'db', ($http) ->
  class DB
    constructor: (@dbUrl) ->

    _encodeOptions: (options) ->
      buf = [];
      if options? and angular.isObject(options)
        for key, value of options
          if key in ["key", "startkey", "endkey"]
            value = JSON.stringify(value)
          buf.push(encodeURIComponent(key) + "=" + encodeURIComponent(value))
      return if buf.length then "?" + buf.join("&") else ""


    _getMultipartSeparator: (reply) ->
      re = new RegExp('^(--[0-9a-f]{32})')
      sep = re.exec(reply)
      if sep?
        return sep[1]
      return null

    _isMultipart: (reply) ->
      sep = @_getMultipartSeparator(reply)
      return sep?

    _getJsonPart: (str) ->
      str = '{' + str.split('{')[1..].join('{')
      return JSON.parse(str)

    _parseReply: (reply) ->
      sep = @_getMultipartSeparator(reply)
      parts = reply.split(sep)
      doc = @_getJsonPart(parts[1])
      if parts.length > 2
        doc.data = @_getJsonPart(parts[2])
        delete doc._attachments
      return doc

    get: (_id) ->
      $http.get(@dbUrl + _id +  @_encodeOptions({attachments: true}))
      .then (result) =>
        if @_isMultipart(result.data)
          return @_parseReply(result.data)
        else
          return result.data

    _toAttachment: (doc) ->
      if doc.data?
        data = doc.data
        doc._attachments =
          "data":
            "data": btoa(JSON.stringify(data))
        delete doc.data

    put: (doc) ->
      @_toAttachment(doc)

      $http.put(@dbUrl + doc._id, doc, {
        'Content-Type': "application/json"
      }).then (result) =>
        return result.data

    post: (doc) ->
      @_toAttachment(doc)

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
