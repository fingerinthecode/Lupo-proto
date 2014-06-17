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
      t0 = performance.now()
      $http.get(@dbUrl + _id +  @_encodeOptions({attachments: true}), {
        headers:
          'Accept-Encoding': 'deflate'
      })
      .then (result) =>
        t1 = performance.now()
        console.log "download time:", (t1 - t0)
        if @_isMultipart(result.data)
          return @_parseReply(result.data)
        else
          return result.data

    _generateSeparator: (size)->
      if not size
        size = 32
      chars = [0,1,2,3,4,5,6,7,8,9,'a','b','c','d','e','f']
      result = ''
      for i in [0..size-1]
        result += chars[Math.floor(Math.random()*16)]
      return result

    _toAttachment: (doc) ->
      boundary = @_generateSeparator()
      if doc.data?
        data = JSON.stringify(doc.data)
        doc._attachments =
          "data":
            "follows": true
            "content_type": "application/json"
            "length": data.length
        delete doc.data
      strDoc = "\r\n--" + boundary + "\r\n"
      strDoc += "Content-Type: application/json\r\n\r\n"
      strDoc += JSON.stringify doc
      if doc._attachments?
        strDoc += "\r\n\r\n--" + boundary + "\r\n\r\n"
        strDoc += data
      strDoc += "\r\n--" + boundary + "--\r\n"
      console.debug strDoc[0..100], strDoc[-100..-1]
      return [strDoc, boundary]


    put: (doc) ->
      [strDoc, boundary] = @_toAttachment(doc)
      t0 = performance.now()
      $http.put(@dbUrl + doc._id, strDoc, {
        transformRequest: angular.identity
        headers:
          'Content-Type': "multipart/related;boundary=\"#{boundary}\""
      }).then (result) =>
        t1 = performance.now()
        console.log "upload time:", (t1 - t0)
        return result.data

    post: (doc) ->
      doc._id = @_generateSeparator()
      return @put(doc)

    query: (fun, options) ->
      s = fun.split('/')
      ddoc = s[0]
      view = s[1]
      $http.get(@dbUrl + "_design/#{ddoc}/_view/#{view}" + @_encodeOptions(options))
      .then (result) =>
        return result.data
