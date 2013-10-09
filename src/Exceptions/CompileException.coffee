util = require 'util'

AbstractException = require './AbstractException'

CompileException = (message) ->
	CompileException.super_.call(@, message, @constructor)

util.inherits(CompileException, AbstractException)
CompileException.prototype.name = 'Compile Exception'

module.exports = CompileException