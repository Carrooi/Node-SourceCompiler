Q = require 'q'
eco = require 'eco'

Compiler = require './Compiler'
InvalidArgumentException = require '../Exceptions/InvalidArgumentException'

class Eco extends Compiler


	getMinifier: -> return 'uglify'


	parse: (data, options = {}) ->
		if options.minify == true && options.jquerify == true

		else if options.minify == true
			return Q.reject(new InvalidArgumentException 'Minifing eco templates is not implemented')

		if options.precompile == true
			data = eco.precompile(data)
			if options.jquerify == true
				data = Compiler.jquerify.precompiled(data)
		else
			data = eco.render(data, options.data)
			if options.jquerify == true
				data = Compiler.jquerify.compiled(data)

		return Q.resolve(data)


module.exports = Eco