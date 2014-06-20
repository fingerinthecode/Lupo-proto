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

    get: (_id) ->
      t0 = performance.now()
      $http.get(@dbUrl + _id)
      .then (result) =>
        t1 = performance.now()
        console.log "download time:", (t1 - t0)
        doc = result.data
        if doc._attachments? and doc._attachments.data?
          return @get(_id + '/data').then (data) =>
            t2 = performance.now()
            console.log "full download time:", (t2 - t0)
            data = atob data
            if doc.data?
              doc.data.data = data
            else
              doc.data = data
            delete doc._attachments
            return doc
        else
          return doc

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
      if doc.data? and angular.isObject(doc.data) and doc.data.data?
        #data = new Uint8Array(doc.data.data.length)
        #for i in [0..doc.data.data.length-1]
        #  data[i] = doc.data.data.charCodeAt(i)
        #data = @bin2String(doc.data.data)
        data = btoa doc.data.data
        doc._attachments =
          "data":
            "follows": true
            "content_type": "application/octet-stream"
            "length": data.length
        delete doc.data.data
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
      $http.get(
        @dbUrl + "_design/#{ddoc}/_view/#{view}" +
        if options? then @_encodeOptions(options) else ""
      )
      .then (result) =>
        return result.data
