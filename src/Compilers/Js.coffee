Q = require 'q'

Compiler = require './Compiler'

class Js extends Compiler


	getMinifier: -> return 'uglify'


	parse: (data, options = {}) ->
		return Q.resolve(data)


module.exports = Js