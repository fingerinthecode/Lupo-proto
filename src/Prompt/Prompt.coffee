angular.module('prompt').
factory('Prompt', ($document, $q, $compile, $rootScope)->
  return class Prompt
    @body: $document.find('body')
    @template:  """
                <div id="prompt" class="modal" ng-click="reject($event)">
                  <div class="modal-container" ng-click="$event.stopPropagation()">
                    <div class="modal-header">
                      <h2 translate>{{ title }}</h2>
                    </div>
                    <div class="modal-content">
                      <p translate>{{ content }}</p>
                    </div>
                    <div class="modal-footer">
                      <button class="button button-{{k}}"  ng-repeat="(k,o) in options" ng-click="resolve($event, k)" translate>{{o}}</button>
                      <button class="button button-cancel" ng-click="reject($event)"  translate>Cancel</button>
                    </div>
                  </div>
                </div>
                """

    @ask: (title, content, options={ok: "Ok"})->
      defer = $q.defer()
      html  = null

      if $document[0].getElementById('prompt') == null
        scope = $rootScope.$new()
        scope.title   = title
        scope.content = content
        scope.options = options
        scope.resolve = ($event, name)->
          html.remove()
          defer.resolve(name)

        scope.reject  = ($event)->
          defer.reject()
          if $event.target == html[0]
            html.remove()

        html = $compile(@template)(scope)
        @body.append(html)
      return defer.promise

)
