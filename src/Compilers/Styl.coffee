Q = require 'q'
stylus = require 'stylus'
path = require 'path'

Compiler = require './Compiler'
SyntaxException = require '../Exceptions/SyntaxException'

class Styl extends Compiler


	isCachableWithDependencies: -> return true


	getMinifier: -> return 'cleanCss'


	parse: (data, options = {}) ->
		deferred = Q.defer()

		styl = stylus(data)

		if options.path != null
			styl.include(path.dirname(options.path))

		styl.render( (err, data) =>
			if err
				deferred.reject(@parseError(err, options.path))
			else
				deferred.resolve(data)
		)

		return deferred.promise


	parseError: (error, _path) ->
		data = error.message.split('\n')

		line = data[0].match(/\:(\d+)$/)[1]
		message = data[data.length - 2]

		e = new SyntaxException(message)
		e.filename = _path
		e.line = parseInt(line)
		e.column = null

		return e


module.exports = Styl