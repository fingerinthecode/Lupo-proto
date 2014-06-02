angular.module('translation').
factory('Local', (CouchDB, db)->
  return CouchDB(db.url, db.name, 'local')
)
