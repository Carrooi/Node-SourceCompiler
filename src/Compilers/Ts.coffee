Q = require 'q'
path = require 'path'
exec = require('child_process').exec
fs = require 'fs'

Compiler = require './Compiler'
CompileException = require '../Exceptions/CompileException'
SyntaxException = require '../Exceptions/SyntaxException'

class Ts extends Compiler


	@ESCAPE_PATTERN = ['.', '[', ']', '\\', '/', '^', '$', '|', '?', '+', '(', ')', '{', '}']


	getMinifier: -> return 'js'


	parse: (data, options = {}) ->
		if options.path == null
			return Q.reject(new CompileException 'You have to set path for compiling typescript.')

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
		replace = []
		replace.push('\\' + char) for char in Ts.ESCAPE_PATTERN
		p = _path.replace(new RegExp('(' + replace.join('|') + ')', 'g'), '\\$1')

		message = error.message.replace(/\n$/, '')

		r = new RegExp('^Command\\sfailed\\:\\s' + p + '\\((\\d+)\\,(\\d+)\\)\\:\\serror\\sTS(\\d+)\\:\\s(.+)$')
		match = message.match(r)

		e = new SyntaxException(match[4])
		e.filename = _path
		e.line = parseInt(match[1])
		e.column = parseInt(match[2])
		e.code = parseInt(match[3])

		return e


module.exports = Ts