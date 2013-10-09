util = require 'util'

AbstractException = require './AbstractException'

SyntaxException = (message) ->
	SyntaxException.super_.call(@, message, @constructor)

util.inherits(SyntaxException, AbstractException)
SyntaxException.prototype.name = 'Syntax Exception'
SyntaxException.prototype.filename = null
SyntaxException.prototype.line = null
SyntaxException.prototype.column = null
SyntaxException.prototype.lastLine = null
SyntaxException.prototype.lastColumn = null

module.exports = SyntaxException