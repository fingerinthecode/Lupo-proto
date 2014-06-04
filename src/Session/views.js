
exports.getUserByName = {
  map: function(doc) {
    if (doc.hasOwnProperty('publicKey') && doc.hasOwnProperty('name')) {
      emit(doc.name, doc);
    }
  }
}

exports.getShares = {
  map: function(doc) {
    if (doc.hasOwnProperty('userId') && doc.hasOwnProperty('data')) {
      emit(doc.userId, doc.data);
    }
  }
}
