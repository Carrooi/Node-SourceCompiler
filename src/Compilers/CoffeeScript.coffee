Q = require 'q'
coffee = require 'coffee-script'

Compiler = require './Compiler'
CompileException = require '../Exceptions/CompileException'
SyntaxException = require '../Exceptions/SyntaxException'

class CoffeeScript extends Compiler


	getMinifier: -> return 'js'


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


	parseError: (error, _path = null) ->
		if error instanceof SyntaxError
			e = new SyntaxException(error.message)
			e.filename = _path
			e.line = error.location.first_line
			e.column = error.location.first_column
			e.lastLine = error.location.last_line
			e.lastColumn = error.location.last_column
		else
			e = new CompileException(error.message)
			e.filename = _path

		return e


module.exports = CoffeeScript