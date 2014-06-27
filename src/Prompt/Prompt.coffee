angular.module('prompt').
factory('Prompt', ($document, $q, $compile, $rootScope)->
  return class Prompt
    @body: $document.find('body')
    @template:  """
                <div class="modal prompt" ng-click="reject($event)">
                  <div class="modal-container">
                    <div class="modal-header">
                      <h2 translate>{{ title }}</h2>
                    </div>
                    <div class="modal-content">
                      <p translate>{{ content }}</p>
                    </div>
                    <div class="modal-footer">
                      <button class="button button-ok"     ng-click="resolve($event)" translate>Ok</button>
                      <button class="button button-cancel" ng-click="reject($event)"  translate>cancel</button>
                    </div>
                  </div>
                </div>
                """

    @ask: (title, content)->
      defer = $q.defer()
      html  = null

      if $document[0].getElementsByClassName('prompt').length == 0
        scope = $rootScope.$new()
        scope.title   = title
        scope.content = content
        scope.resolve = ($event)->
          defer.resolve()
          html.remove()
          $event.preventDefault()
          $event.stopPropagation()

        scope.reject  = ($event)->
          defer.reject()
          html.remove
          $event.preventDefault()
          $event.stopPropagation()

        html = $compile(@template)(scope)
        console.info html
        @body.append(html)
      return defer.promise

)
