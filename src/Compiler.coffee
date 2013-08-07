path = require 'path'
Q = require 'q'
fs = require 'fs'
coffee = require 'coffee-script'
less = require 'less'
stylus = require 'stylus'
sass = require 'node-sass'
uglify = require 'uglify-js'
cleanCss = require 'clean-css'
exec = require('child_process').exec

class Compiler


	@minifiers:
		coffee: 'uglify'
		json: 'uglify'
		ts: 'uglify'
		less: 'cleanCss'
		scss: 'cleanCss'
		styl: 'cleanCss'


	@isSupported: (type) ->
		return typeof @_compilers[type] != 'undefined'


	@getType: (_path) ->
		return path.extname(_path).replace(/^\./, '')


	@compileFile: (_path, options = {}) ->
		_path = path.resolve(_path)
		type = @getType(_path)
		options.path = _path
		deferred = Q.defer()

		fs.readFile(_path, encoding: 'utf-8', (err, data) =>
			if err
				deferred.reject(err)
			else
				@compile(type, data, options).then( (data) -> deferred.resolve(data) )
		)

		return deferred.promise


	@compile: (type, data, options = {}) ->
		if typeof options.path == 'undefined' then options.path = null
		if typeof options.minify == 'undefined' then options.minify = false
		if typeof options.debug == 'undefined' then options.debug = false

		if !@isSupported(type)
			return Q.reject(new Error "Type '#{type}' is not supported")

		deferred = Q.defer()
		@_compilers[type](data, options).then( (data) =>
			if options.minify then data = @_minify[@minifiers[type]](data)
			deferred.resolve(data)
		, (err) ->
			deferred.reject(err)
		)
		return deferred.promise


	@_compilers:
		coffee: (data, options) =>
			setup =
				literate: false

			if options.path != null
				setup.filename = options.path

			deferred = Q.defer()
			try
				deferred.resolve(coffee.compile(data, setup))
			catch err
				deferred.reject(@_errors.coffee(err, options.path))

			return deferred.promise

		json: (data, options) =>
			deferred = Q.defer()
			deferred.resolve("(function() {\nreturn #{data}\n}).call(this);\n")
			return deferred.promise


		ts: (data, options) =>
			if options.path == null
				return Q.reject(new Error 'You have to set path for compiling typescript')

			deferred = Q.defer()
			dir = path.dirname(options.path)
			name = path.basename(options.path, path.extname(options.path))
			fileName = "#{dir}/#{name}.js"
			ts = path.resolve("#{__dirname}/../node_modules/typescript/bin/tsc.js")

			exec("node #{ts} #{options.path}", (err, stdout, stderr) =>
				if err
					deferred.reject(@_errors.ts(err, options.path))
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

		less: (data, options) =>
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
						deferred.reject(@_errors.less(err, options.path))
					else
						deferred.resolve(data)
				)
			catch err
				deferred.reject(@_errors.less(err, options.path))

			return deferred.promise

		scss: (data, options) =>
			deferred = Q.defer()
			setup =
				data: data

			if options.path != null
				setup.includePaths = [path.dirname(options.path)]

			try
				data = sass.renderSync(setup)
				deferred.resolve(data)
			catch err
				deferred.reject(@_errors.scss(err, options.path))

			return deferred.promise

		styl: (data, options) =>
			deferred = Q.defer()

			styl = stylus(data)

			if options.path != null
				styl.include(path.dirname(options.path))

			styl.render( (err, data) =>
				if err
					deferred.reject(@_errors.styl(err, options.path))
				else
					deferred.resolve(data)
			)

			return deferred.promise


	@_minify:
		uglify: (data) -> return uglify.minify(data, fromString: true).code
		cleanCss: (data) -> return cleanCss.process(data)


	@_errors:
		coffee: (err, path = null) ->
			return err

		json: (err, path = null) ->
			return err

		ts: (err, path = null) ->
			e = new Error err.message.replace(/^Command\sfailed\:\s/, '')
			e.filename = path

			return e

		less: (err, path = null) ->
			msg = err.type + 'Error: ' + err.message.replace(/[\s\.]+$/, '')
			msg += if err.filename != null then " in #{err.filename}:" else ' on line '
			msg += "#{err.line}:#{err.column}"

			e = new Error msg
			e.type = err.type
			e.filename = err.filename
			e.line = err.line
			e.column = err.column

			return e

		scss: (err, path = null) ->
			data = err.message.split('\n')[0].match(/^\:(\d+)\:\serror\:\s(.*)/)
			line = data[1]
			msg = data[2]
			msg += if path != null then " in #{path}:" else ' on line '
			msg += line

			e = new Error msg
			e.type = err.name
			e.filename = path
			e.line = line

			return e

		styl: (err, path = null) ->
			data = err.message.split('\n')
			line = data[0].split(':')[1]
			msg = data[data.length - 2]
			msg += if path != null then " in #{path}:" else ' on line '
			msg += line

			e = new Error msg
			e.filename = path
			e.line = line

			return e


module.exports = Compiler