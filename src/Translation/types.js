var Type              = require('couchtypes/types').Type;
var permissions       = require('couchtypes/permissions');
var activityField     = require('../Activity/fields').activityField;

exports.local = new Type('local', {
  permissions: {
    add: permissions.loggedIn(),
    update: permissions.loggedIn(),
    remove: permissions.hasRole('_admin')
  },
  fields: {
    activity: activityField(),
  },
});
