Q = require 'q'
path = require 'path'
less = require 'less'

Compiler = require './Compiler'
CompileException = require '../Exceptions/CompileException'
SyntaxException = require '../Exceptions/SyntaxException'

class Less extends Compiler


	isCachableWithDependencies: -> return true


	getMinifier: -> return 'css'


	parse: (data, options = {}) ->
		setup =
			optimization: 1
			rootpath: ''
			relativeUrls: false
			strictImports: false

		if options.path != null
			setup.paths = [path.dirname(options.path)]
			setup.filename = options.path

		if options.debug == true
			setup.dumpLineNumbers = 'mediaquery'

		deferred = Q.defer()
		try
			less.render(data, setup, (err, data) =>
				if err
					deferred.reject(@parseError(err, options.path))
				else
					deferred.resolve(data)
			)
		catch err
			deferred.reject(@parseError(err, options.path))

		return deferred.promise


	parseError: (error, _path) ->
		if error.type == 'File'
			e = new CompileException(error.message)
		else
			e = new SyntaxException(error.message)

		e.filename = _path
		e.line = error.line
		e.column = error.column
		e.type = error.type

		return e


module.exports = Less