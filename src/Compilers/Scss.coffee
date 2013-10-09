Q = require 'q'
path = require 'path'
sass = require 'node-sass'

Compiler = require './Compiler'
SyntaxException = require '../Exceptions/SyntaxException'
CompileException = require '../Exceptions/CompileException'

class Scss extends Compiler


	isCachableWithDependencies: -> return true


	getMinifier: -> return 'css'


	parse: (data, options = {}) ->
		deferred = Q.defer()

		setup =
			data: data
			success: (css) -> deferred.resolve(css)
			error: (err) => deferred.reject(@parseError(err, options.path))

		if options.path != null
			setup.includePaths = [path.dirname(options.path)]

		sass.render(setup)

		return deferred.promise


	parseError: (error, _path) ->
		data = error.match(/^source\sstring\:(\d+)\:\serror\:\s(.*)/)

		if data[2].match(/^file\sto\simport\snot\sfound\sor\sunreadable/)
			e = new CompileException(data[2])
		else
			e = new SyntaxException(data[2])

		e.filename = _path
		e.line = parseInt(data[1])
		e.column = null

		return e


module.exports = Scss