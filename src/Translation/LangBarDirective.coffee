angular.module('translation').
directive('langBar', ($rootScope) ->
  return {
    restrict: 'E'
    scope: {
      langs:     '='
      allLangs:  '='
      lang:      '='
      nbCard:    '='
    }
    template: """
              <div class="btn-group">
                <button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown" ng-disabled="translateMode">
                  <img src="img/country-flags-png/{{lang}}.png"/>
                  <span class="caret"></span>
                </button>
                <ul class="dropdown-menu">
                  <li ng-repeat="(key, value) in langs">
                    <a ng-click="changeLangue(key)"><img src="img/country-flags-png/{{key}}.png"/> ({{ (value / nbCard * 100).toFixed(2) }} %)</a>
                  </li>
                </ul>
              </div>
              <div class="btn-group" ng-hide="translateMode">
                <button ng-disabled="disable" type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown">
                  Help Translate
                </button>
                <ul class="dropdown-menu">
                  <li ng-repeat="(key, value) in allLangs">
                    <a ng-click="addLangue(key)"><img src="img/country-flags-png/{{key}}.png"/>{{value}}</a>
                  </li>
                </ul>
              </div>
              <button ng-show="translateMode" ng-click="stopTranslate()" ng-disabled="disable" class="btn btn-default">
                Stop Translate
              </button>
              """

    link: (scope, element, attrs) ->
      scope.translateMode = false

      $rootScope.$on('SignIn', ->
        scope.disable = false
      )
      $rootScope.$on('SignOut', ->
        scope.disable = true
      )

      scope.changeLangue = (key) ->
        scope.lang = key
        $rootScope.$broadcast('LangBarChangeLanguage', key)
        scope.stopTranslate()

      scope.addLangue = (key) ->
        $rootScope.$broadcast('LangBarChangeLanguage', key)
        scope.translateMode = true
        scope.lang          = key
        scope.langs[key]    = scope.langs[key] ? 0
        $rootScope.$broadcast('LangBarNewLanguage', key)

      scope.stopTranslate = ->
        scope.translateMode = false
        $rootScope.$broadcast('LangBarStopTranslate')
  }
)
