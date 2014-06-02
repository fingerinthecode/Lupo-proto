angular.module('lupo-proto', [
  'ui.router'
  'gettext'
  'translation'
  'angularSpinner'
  'session'
  'crypto'
  'pouchdb'
  'fileManager'
  'ng-context-menu'
]).value('db', [
  'name': 'proto'
  'url':  ''
])
