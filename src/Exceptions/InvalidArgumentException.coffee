util = require 'util'

AbstractException = require './AbstractException'

InvalidArgumentException = (message) ->
	InvalidArgumentException.super_.call(@, message, @constructor)

util.inherits(InvalidArgumentException, AbstractException)
InvalidArgumentException.prototype.name = 'Invalid Argument Exception'

module.exports = InvalidArgumentException