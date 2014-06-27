angular.module('watcher').
factory('Watcher', ($http, dbname, $location, $rootScope)->
  return class Watcher
    @filter: null

    @start: (filter = null)->
      @filter = filter
      @watcher()

    @watcher: (since = 'now')->
      dbUrl  = $location.absUrl().split('#')[0]
      dbUrl += "#{dbname}/"

      params = {
          since: since
          feed:  'longpoll'
          heartbeat: 1000
      }

      if @filter?
        params.filter = @filter

      $http({
        method: 'GET'
        url:    "#{dbUrl}/_changes"
        params: params
      }).then(
        (data)=>
          data = data.data
          if data.last_seq?
            for change in data.results ? []
              $rootScope.$broadcast('Changes', change.id)
            @watcher(data.last_seq)
        ,(err)=>
          console.info err
      )
)
