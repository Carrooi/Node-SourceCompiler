Q = require 'q'
path = require 'path'
sass = require 'node-sass'

Compiler = require './Compiler'
SyntaxException = require '../Exceptions/SyntaxException'

class Scss extends Compiler


	isCachableWithDependencies: -> return true


	getMinifier: -> return 'cleanCss'


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

		e = new SyntaxException(data[2])
		e.filename = _path
		e.line = parseInt(data[1])
		e.column = null

		return e


module.exports = Scss