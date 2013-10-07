expect = require('chai').expect
fs = require 'fs'
path = require 'path'

Compiler = require '../../lib/Compiler'

dir = path.resolve(__dirname + '/../data')

loadFile = (_path) -> return fs.readFileSync(dir + '/' + _path, encoding: 'utf8')

describe 'Compiler.cache', ->

	beforeEach( ->
		Compiler.setCache(dir + '/cache')
	)

	afterEach( ->
		Compiler.cache = null
		file = dir + '/cache/__' + Compiler.CACHE_NAMESPACE + '.json'
		if fs.existsSync(file)
			fs.unlinkSync(file)
	)

	it 'should be null when coffee file is not in cache', ->
		expect(Compiler.cache.load(dir + '/coffee/simple.coffee')).to.be.null

	it 'should save compiled coffee file to cache', (done) ->
		Compiler.compileFile(dir + '/coffee/simple.coffee').then( (data) ->
			expect(Compiler.cache.load(dir + '/coffee/simple.coffee')).to.be.equal("(function() {\n  var message;\n\n  message = 'hello';\n\n}).call(this);\n")
			done()
		).done()

	it 'should load compiled coffee file from cache', (done) ->
		Compiler.compileFile(dir + '/coffee/simple.coffee').then( (data) ->
			Compiler.compileFile(dir + '/coffee/simple.coffee').then( (data) ->
				expect(data).to.be.equal("(function() {\n  var message;\n\n  message = 'hello';\n\n}).call(this);\n")
				done()
			).done()
		).done()

	it 'should not save less file to cache', (done) ->
		Compiler.compileFile(dir + '/less/simple.less').then( (data) ->
			expect(Compiler.cache.load(dir + '/less/simple.less')).to.be.null
			done()
		).done()

	it 'should save less file to cache if dependents are defined', (done) ->
		Compiler.compileFile(dir + '/less/simple.less', {dependents: []}).then( (data) ->
			expect(Compiler.cache.load(dir + '/less/simple.less')).to.be.equal('body {\n  color: #ff0000;\n}\n')
			done()
		).done()