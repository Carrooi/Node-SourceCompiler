Q = require 'q'

Compiler = require './Compiler'

class Json extends Compiler


	getMinifier: -> return 'uglify'


	parse: (data, options = {}) ->
		return Q.resolve("(function() {\nreturn #{data}\n}).call(this);\n")


module.exports = Json