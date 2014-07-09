module.exports = {
  rewrites: require('./rewrites'),
  views: require('./views'),
  language: "javascript",
  filters: {
    newUser: function (doc, req) {
      log(doc);
      return doc.hasOwnProperty('publicKey') &&
             doc.hasOwnProperty('name')      &&
             parseInt(doc._rev) == 1;
    }
  }
}
