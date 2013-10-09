path = require 'path'
Q = require 'q'
fs = require 'fs'
Cache = require 'cache-storage'
FileStorage = require 'cache-storage/Storage/FileStorage'
Finder = require 'fs-finder'
http = require 'http'
https = require 'https'

BaseCompiler = require './Compilers/Compiler'
Helpers = require './Helpers'
HttpGetException = require './Exceptions/HttpGetException'
InvalidArgumentException = require './Exceptions/InvalidArgumentException'

class Compiler


	CACHE_NAMESPACE = 'source_compiler'


	cache: null

	compilers: null


	constructor: ->
		@compilers = {}

		@addCompiler('coffee', new (require('./Compilers/CoffeeScript')));
		@addCompiler('eco', new (require('./Compilers/Eco')));
		@addCompiler('js', new (require('./Compilers/Js')));
		@addCompiler('json', new (require('./Compilers/Json')));
		@addCompiler('less', new (require('./Compilers/Less')));
		@addCompiler('scss', new (require('./Compilers/Scss')));
		@addCompiler('styl', new (require('./Compilers/Styl')));
		@addCompiler('ts', new (require('./Compilers/Ts')));


	addCompiler: (name, compiler) ->
		if compiler !instanceof BaseCompiler
			throw new InvalidArgumentException 'Compiler must be an instance of Compilers/Compiler.'

		@compilers[name] = compiler

		return @


	hasCompiler: (name) ->
		return typeof @compilers[name] != 'undefined'


	getCompiler: (name) ->
		return if @hasCompiler(name) then @compilers[name] else null


	setCache: (_path) ->
		@cache = new Cache(new FileStorage(_path), @CACHE_NAMESPACE)


	setCacheStorage: (storage) ->
		@cache = new Cache(storage, @CACHE_NAMESPACE)


	# deprecated
	isSupported: (type) ->
		return @hasCompiler(type)


	isRemote: (_path) ->
		return _path.match(/^https?\:\/\//) != null


	getType: (_path) ->
		return path.extname(_path).replace(/^\./, '')


	loadFile: (type, _path, options) ->
		deferred = Q.defer()
		if @isRemote(_path)
			protocol = if _path.match(/^https/) then https else http
			protocol.get(_path, (res) =>
				data = ''
				res.setEncoding('utf-8')
				res.on('data', (chunk) ->
					data += chunk
				)
				res.on('end', =>
					@compile(type, data, options).then( (data) ->
						deferred.resolve(data)
					).fail( (err) ->
						deferred.reject(err)
					)
				)
			).on('error', (e) ->
				deferred.reject(new HttpGetException e)
			)
		else
			fs.readFile(_path, encoding: 'utf-8', (err, data) =>
				if err
					deferred.reject(err)
				else
					@compile(type, data, options).then( (data) ->
						deferred.resolve(data)
					).fail( (err) ->
						deferred.reject(err)
					)
			)
		return deferred.promise


	compileFile: (_path, options = {}) ->
		if !@isRemote(_path) then _path = path.resolve(_path)
		type = @getType(_path)
		if !@isRemote(_path) then options.path = _path
		deferred = Q.defer()

		if @cache == null || (@getCompiler(type).isCachableWithDependencies() && typeof options.dependents == 'undefined') || @isRemote(_path)
			@loadFile(type, _path, options).then( (data) ->
				deferred.resolve(data)
			, (err) ->
				deferred.reject(err)
			)
		else
			result = @cache.load(_path)
			options.dependents = if typeof options.dependents == 'undefined' then [_path] else options.dependents.concat([_path])
			options.dependents = @parseDependents(options.dependents)
			if result == null
				@loadFile(type, _path, options).then( (data) =>
					@cache.save(_path, data,
						files: options.dependents
					)
					deferred.resolve(data)
				, (err) ->
					deferred.reject(err)
				)
			else
				deferred.resolve(result)

		return deferred.promise


	compile: (type, data, options = {}) ->
		if typeof options.path == 'undefined' then options.path = null
		if typeof options.minify == 'undefined' then options.minify = false
		if typeof options.debug == 'undefined' then options.debug = false
		if typeof options.precompile == 'undefined' then options.precompile = false
		if typeof options.jquerify == 'undefined' then options.jquerify = false
		if typeof options.data == 'undefined' then options.data = {}
		if typeof options.dependents == 'undefined' then options.dependents = []

		if !@hasCompiler(type)
			return Q.reject(new InvalidArgumentException "Type #{type} is not supported.")

		deferred = Q.defer()

		compiler = @getCompiler(type)
		compiler.parse(data, options).then( (data) =>
			if options.minify
				minifier = compiler.getMinifier(options)
				data = Helpers.minify[minifier](data)

			deferred.resolve(data)
		, (err) ->
			deferred.reject(err)
		)
		return deferred.promise


	parseDependents: (dependents) ->
		result = []
		for _path in dependents
			if _path.match(/^http/) != null
				result.push(_path)
			else if fs.existsSync(_path) && fs.statSync(_path).isFile()
				result.push(_path)
			else
				result = result.concat(Finder.findFiles(_path))

		return result


module.exports = new Compiler