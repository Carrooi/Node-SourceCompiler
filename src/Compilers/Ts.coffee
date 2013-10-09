Q = require 'q'
path = require 'path'
exec = require('child_process').exec
fs = require 'fs'

Compiler = require './Compiler'
InvalidArgumentException = require '../Exceptions/InvalidArgumentException'
CompileException = require '../Exceptions/CompileException'

class Ts extends Compiler


	getMinifier: -> return 'uglify'


	parse: (data, options = {}) ->
		if options.path == null
			return Q.reject(new InvalidArgumentException 'You have to set path for compiling typescript')

		deferred = Q.defer()
		dir = path.dirname(options.path)
		name = path.basename(options.path, path.extname(options.path))
		fileName = "#{dir}/#{name}.js"
		ts = path.resolve("#{__dirname}/../../node_modules/typescript/bin/tsc.js")

		exec("node #{ts} #{options.path}", (err, stdout, stderr) =>
			if err
				deferred.reject(@parseError(err, options.path))
			else
				fs.readFile(fileName, 'utf-8', (err, content) =>
					fs.unlink(fileName)
					if err
						deferred.reject(err)
					else
						deferred.resolve(content)
				)
		)

		return deferred.promise


	parseError: (error, _path) ->
		e = new CompileException error.message.replace(/^Command\sfailed\:\s/, '')
		e.filename = _path

		return e


module.exports = Ts