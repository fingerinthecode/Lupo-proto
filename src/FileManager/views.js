exports.getShares = {
  map: function(doc) {
    if (doc.hasOwnProperty('userId')) {
      emit(doc.userId, doc._id);
    }
  }
}