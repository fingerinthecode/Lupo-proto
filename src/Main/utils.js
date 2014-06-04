exports.assert = function (assertion, message) {
  if(assertion === false)
    throw new Error(message || 'unauth');
}

exports.reExports = function (exports, path) {
  var exported = require(path)
  for(var element in exported) {
    exports[element] = exported[element];
  }
}
