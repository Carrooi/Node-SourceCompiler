util = require 'util'

AbstractException = require './AbstractException'

SyntaxException = (message) ->
	SyntaxException.super_.call(@, message, @constructor)

util.inherits(SyntaxException, AbstractException)
SyntaxException.prototype.name = 'Syntax Exception'

module.exports = SyntaxException