angular.module('crypto').
factory 'CrypTree', ($q, crypto, cache, storage) ->
  class CrypTree
    @symLink: (parentKey, key) ->
      console.debug "symLink", parentKey, key
      crypto.symEncrypt parentKey, key

    @resolveSymLink: (link, key) ->
      console.debug "resolveSymLink", link, key
      crypto.symDecrypt key, link
      .then (resultKey) =>
        if resultKey.length != crypto.keyLength
          console.error "resolveSymLink error", link, key, resultKey
          throw "Unable to resolve symLink"
        return resultKey

    @asymLink: (k1, k2) ->
      updateAsymLink {publicKey: k1.public}, k2

    @resolveAsymLink: (link, key) ->
      crypto.asymDecrypt key.private, link.link

    @updateAsymLink: (link, newKey) ->
      crypto.asymEncrypt link.publicKey, newKey
      .then (data) =>
        return {
          link: data,
          publicKey: link.publicKey
        }
