Q = require 'q'
coffee = require 'coffee-script'

Compiler = require './Compiler'

class CoffeeScript extends Compiler


	getMinifier: -> return 'uglify'


	parse: (data, options = {}) ->
		setup =
			literate: false

		if options.path != null
			setup.filename = options.path

		deferred = Q.defer()
		try
			deferred.resolve(coffee.compile(data, setup))
		catch err
			deferred.reject(@parseError(err, options.path))

		return deferred.promise


	parseError: (error, path) ->
		
		return error


module.exports = CoffeeScript