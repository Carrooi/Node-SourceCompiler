util = require 'util'

AbstractException = (message = 'Error', constr = @) ->
	Error.captureStackTrace(@, constr)
	@message = message

util.inherits(AbstractException, Error)
AbstractException.prototype.name = 'Abstract Exception'

module.exports = AbstractException