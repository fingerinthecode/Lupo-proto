angular.module('lupo-proto', [
  'ui.router'
  'gettext'
  'notification'
  'translation'
  'angularSpinner'
  'session'
  'crypto'
  'db'
  'fileManager'
  'ng-context-menu'
]).value('db', [
  'name': 'proto'
  'url':  ''
])
