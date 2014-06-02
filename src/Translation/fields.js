var fields = require('couchtypes/fields');
var _      = require('underscore');

exports.translatableField = function (options) {
  return new fields.Field(_.defaults(options || {}, {
    translatable: true
  }))
}
