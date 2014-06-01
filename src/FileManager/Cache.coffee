angular.module('fileManager').
factory 'cache', () ->
  {
    _data: {}

    get: (id, type) ->
      if this._data[id]?
        return this._data[id][type]

    store: (id, type, value) ->
      unless this._data[id]?
        this._data[id] = {}
      this._data[id][type] = value

    expire: (id) ->
      delete this._data[id]

    #TODO: watcher of changes
  }