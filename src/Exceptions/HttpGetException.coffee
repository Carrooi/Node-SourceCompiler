util = require 'util'

AbstractException = require './AbstractException'

HttpGetException = (message) ->
	HttpGetException.super_.call(@, message, @constructor)

util.inherits(HttpGetException, AbstractException)
HttpGetException.prototype.name = 'Http Get Exception'

module.exports = HttpGetException