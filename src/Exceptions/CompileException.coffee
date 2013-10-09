util = require 'util'

AbstractException = require './AbstractException'

CompileException = (message) ->
	CompileException.super_.call(@, message, @constructor)

util.inherits(CompileException, AbstractException)
CompileException.prototype.name = 'Compile Exception'
CompileException.prototype.filename = null
CompileException.prototype.line = null
CompileException.prototype.column = null
CompileException.prototype.lastLine = null
CompileException.prototype.lastColumn = null

module.exports = CompileException