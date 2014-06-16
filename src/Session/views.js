
exports.getUserByName = {
  map: function(doc) {
    if (doc.hasOwnProperty('publicKey') && doc.hasOwnProperty('name')) {
      emit(doc.name, doc);
    }
  }
}