Q = require 'q'
path = require 'path'
sass = require 'node-sass'

Compiler = require './Compiler'
CompileException = require '../Exceptions/CompileException'

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
		line = data[1]
		msg = data[2]
		msg += if _path != null then " in #{_path}:" else ' on line '
		msg += line

		e = new CompileException msg
		e.filename = _path
		e.line = line

		return e


module.exports = Scss