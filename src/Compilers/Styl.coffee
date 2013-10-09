Q = require 'q'
stylus = require 'stylus'
path = require 'path'

Compiler = require './Compiler'
CompileException = require '../Exceptions/CompileException'

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
		line = data[0].split(':')[1]
		msg = data[data.length - 2]
		msg += if path != null then " in #{_path}:" else ' on line '
		msg += line

		e = new CompileException msg
		e.filename = _path
		e.line = line

		return e


module.exports = Styl