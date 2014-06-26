Random = require('./Random')
module.exports = class Account
  @username:   Random.string(30)
  @password:   Random.string(30)
  @publicName: Random.string(30)
