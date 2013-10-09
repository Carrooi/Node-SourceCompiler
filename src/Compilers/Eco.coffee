Q = require 'q'
eco = require 'eco'

Compiler = require './Compiler'
InvalidArgumentException = require '../Exceptions/InvalidArgumentException'

class Eco extends Compiler


	getMinifier: (options) ->
		if options.jquerify == true || options.precompile == true
			return 'uglify'
		else
			return 'html'


	parse: (data, options = {}) ->
		deferred = Q.defer()

		if options.precompile == true
			data = eco.precompile(data)
			data = data.replace(/\n/g, '\n  ')
			data = '(function() {\n  return ' + data + '\n}).call(this);'
			if options.jquerify == true
				data = Compiler.jquerify.precompiled(data)
		else
			data = eco.render(data, options.data)
			if options.jquerify == true
				data = Compiler.jquerify.compiled(data)

		deferred.resolve(data)

		return deferred.promise


module.exports = Eco