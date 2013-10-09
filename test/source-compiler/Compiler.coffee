expect = require('chai').expect
fs = require 'fs'
path = require 'path'

Compiler = require '../../lib/Compiler'

dir = path.resolve(__dirname + '/../data')

loadFile = (_path) -> return fs.readFileSync(dir + '/' + _path, encoding: 'utf8')

describe 'Compiler', ->

	describe '#isSupported()', ->
		it 'should return true', ->
			expect(Compiler.isSupported('less')).to.be.true

		it 'should return false', ->
			expect(Compiler.isSupported('jpg')).to.be.false

	describe '#getType()', ->
		it 'should return type of css framework from file', ->
			expect(Compiler.getType('/var/data/css/variables.less')).to.be.equal('less')

	describe '#compile()', ->
		it 'should return error when framework type is not supported', (done) ->
			Compiler.compile('jpg', '').fail( (err) ->
				expect(err).to.be.an.instanceof(Error)
				done()
			).done()

		describe 'coffee', ->
			it 'should return compiled coffee file', (done) ->
				Compiler.compile('coffee', loadFile('coffee/simple.coffee')).then( (data) ->
					expect(data).to.be.equal("(function() {\n  var message;\n\n  message = 'hello';\n\n}).call(this);\n")
					done()
				).done()

			it 'should return error in coffee', (done) ->
				Compiler.compile('coffee', loadFile('coffee/error.coffee')).fail( (err) ->
					expect(err).to.be.an.instanceof(Error)
					done()
				).done()

			it 'should return error in coffee with information about source file', (done) ->
				Compiler.compile('coffee', loadFile('coffee/error.coffee'), {path: dir + '/coffee/error.coffee'}).fail( (err) ->
					expect(err).to.be.an.instanceof(Error)
					done()
				).done()

			it 'should return minified coffee file', (done) ->
				Compiler.compile('coffee', loadFile('coffee/simple.coffee'), {minify: true}).then( (data) ->
					expect(data).to.be.equal('(function(){var l;l="hello"}).call(this);')
					done()
				).done()

		describe 'json', ->
			it 'should return compiled json file', (done) ->
				Compiler.compile('json', loadFile('json/simple.json')).then( (data) ->
					expect(data).to.be.equal('(function() {\nreturn {\n\t"message": "hello"\n}\n}).call(this);\n')
					done()
				).done()

			it 'should return minified json file', (done) ->
				Compiler.compile('json', loadFile('json/simple.json'), {minify: true}).then( (data) ->
					expect(data).to.be.equal('(function(){return{message:"hello"}}).call(this);')
					done()
				).done()

		describe 'js', ->
			it 'should return compiled js file', (done) ->
				Compiler.compile('js', loadFile('js/simple.js')).then( (data) ->
					expect(data).to.be.equal("var message = 'hello';")
					done()
				).done()

		describe 'ts', ->
			it 'should return compiled ts file', (done) ->
				Compiler.compile('ts', loadFile('ts/simple.ts'), {path: dir + '/ts/simple.ts'}).then( (data) ->
					expect(data).to.be.equal("var message = 'hello';\n")
					done()
				).done()

			it 'should return error in ts if path is not defined', (done) ->
				Compiler.compile('ts', loadFile('ts/simple.ts')).fail( (err) ->
					expect(err).to.be.an.instanceof(Error)
					done()
				).done()

			it 'should return minified ts file', (done) ->
				Compiler.compile('ts', loadFile('ts/simple.ts'), {path: dir + '/ts/simple.ts', minify: true}).then( (data) ->
					expect(data).to.be.equal('var message="hello";')
					done()
				).done()

		describe 'less', ->
			it 'should return compiled less file', (done) ->
				Compiler.compile('less', loadFile('less/simple.less')).then( (data) ->
					expect(data).to.be.equal('body {\n  color: #ff0000;\n}\n')
					done()
				).done()

			it 'should return error in less', (done) ->
				Compiler.compile('less', loadFile('less/error.less')).fail( (err) ->
					expect(err).to.be.an.instanceof(Error)
					done()
				).done()

			it 'should return another error', (done) ->
				Compiler.compile('less', 'body {color: @red;}').fail( (err) ->
					expect(err).to.be.an.instanceof(Error)
					done()
				).done()

			it 'should return error in less with information about source file', (done) ->
				Compiler.compile('less', loadFile('less/error.less'), {path: dir + '/less/error.less'}).fail( (err) ->
					expect(err).to.be.instanceof(Error)
					done()
				).done()

			it 'should return compiled less file with imports', (done) ->
				Compiler.compile('less', loadFile('less/import.less'), {path: dir + '/less/import.less'}).then( (data) ->
					expect(data).to.be.equal('body {\n  color: #ff0000;\n}\n')
					done()
				).done()

			it 'should return error if in less are imports and path is not defined', (done) ->
				Compiler.compile('less', loadFile('less/import.less')).fail( (err) ->
					expect(err).to.be.an.instanceof(Error)
					done()
				).done()

			it 'should return minified less styles', (done) ->
				Compiler.compile('less', loadFile('less/simple.less'), {minify: true}).then( (data) ->
					expect(data).to.be.equal('body{color:red}')
					done()
				).done()

		describe 'scss', ->
			it 'should return compiled scss file', (done) ->
				Compiler.compile('scss', loadFile('scss/simple.scss')).then( (data) ->
					expect(data).to.be.equal('body {\n  color: red; }\n')
					done()
				).done()

			it 'should return error in scss', (done) ->
				Compiler.compile('scss', loadFile('scss/error.scss')).fail( (err) ->
					expect(err).to.be.an.instanceof(Error)
					done()
				).done()

			it 'should return error in scss with information about source file', (done) ->
				Compiler.compile('scss', loadFile('scss/error.scss'), {path: dir + '/scss/error.scss'}).fail( (err) ->
					expect(err).to.be.an.instanceof(Error)
					done()
				).done()

			it 'should return compiled scss file with imports', (done) ->
				Compiler.compile('scss', loadFile('scss/import.scss'), {path: dir + '/scss/import.scss'}).then( (data) ->
					expect(data).to.be.equal('body {\n  color: red; }\n')
					done()
				).done()

			it 'should return error if in scss are imports and path is not defined', (done) ->
				Compiler.compile('scss', loadFile('scss/import.scss')).fail( (err) ->
					expect(err).to.be.an.instanceof(Error)
					done()
				).done()

			it 'should return minified scss styles', (done) ->
				Compiler.compile('scss', loadFile('scss/simple.scss'), {minify: true}).then( (data) ->
					expect(data).to.be.equal('body{color:red}')
					done()
				).done()

		describe 'styl', ->
			it 'should return compiled styl file', (done) ->
				Compiler.compile('styl', loadFile('styl/simple.styl')).then( (data) ->
					expect(data).to.be.equal('body {\n  color: #f00;\n}\n')
					done()
				).done()

			it 'should return error in styl', (done) ->
				Compiler.compile('styl', loadFile('styl/error.styl')).fail( (err) ->
					expect(err).to.be.an.instanceof(Error)
					done()
				).done()

			it 'should return error in styl with information about source file', (done) ->
				Compiler.compile('styl', loadFile('styl/error.styl'), {path: dir + '/styl/error.styl'}).fail( (err) ->
					expect(err).to.be.an.instanceof(Error)
					done()
				).done()

			it 'should return compiled styl file with imports', (done) ->
				Compiler.compile('styl', loadFile('styl/import.styl'), {path: dir + '/styl/import.styl'}).then( (data) ->
					expect(data).to.be.equal('body {\n  color: #f00;\n}\n')
					done()
				).done()

			it 'should return error if in styl are imports and path is not defined', (done) ->
				Compiler.compile('styl', loadFile('styl/import.styl')).fail( (err) ->
					expect(err).to.be.an.instanceof(Error)
					done()
				).done()

			it 'should return minified styl styles', (done) ->
				Compiler.compile('styl', loadFile('styl/simple.styl'), {minify: true}).then( (data) ->
					expect(data).to.be.equal('body{color:red}')
					done()
				).done()

		describe 'eco', ->
			it 'should return compiled eco file', (done) ->
				Compiler.compile('eco', loadFile('eco/simple.eco'), {data: {message: 'hello'}}).then( (data) ->
					expect(data).to.be.equal('<span>hello</span>\n<span>Bye</span>')
					done()
				).done()

			it 'should return compiled and jquerified eco file', (done) ->
				Compiler.compile('eco', loadFile('eco/simple.eco'), {jquerify: true, data: {message: 'hello'}}).then( (data) ->
					expect(data).to.be.equal("(function() {\n$('<span>hello</span>' +\n'<span>Bye</span>');\n}).call(this);")
					done()
				).done()

			it 'should return compiled, minified and jquerified eco file', (done) ->
				Compiler.compile('eco', loadFile('eco/simple.eco'), {jquerify: true, minify: true, data: {message: 'hello'}}).then( (data) ->
					expect(data).to.be.equal('(function(){$("<span>hello</span><span>Bye</span>")}).call(this);')
					done()
				).done()

			it 'should return error if you try to minify precompiled eco file', (done) ->
				Compiler.compile('eco', loadFile('eco/simple.eco'), {precompile: true, minify: true}).fail( (err) ->
					expect(err).to.be.an.instanceof(Error)
					done()
				).done()

			it 'should return error if you try to minify clean template', (done) ->
				Compiler.compile('eco', loadFile('eco/simple.eco'), {minify: true, data: {message: 'hello'}}).fail( (err) ->
					expect(err).to.be.an.instanceof(Error)
					done()
				).done()

	describe '#compileFile()', ->

		describe 'coffee', ->
			it 'should return compiled coffee file from compileFile method', (done) ->
				Compiler.compileFile(dir + '/coffee/simple.coffee').then( (data) ->
					expect(data).to.be.equal("(function() {\n  var message;\n\n  message = 'hello';\n\n}).call(this);\n")
					done()
				).done()

			it 'should return compiled coffee file from remote repository', (done) ->
				Compiler.compileFile('https://raw.github.com/sakren/node-source-compiler/master/test/data/coffee/simple.coffee').then( (data) ->
					expect(data).to.be.equal("(function() {\n  var message;\n\n  message = 'hello';\n\n}).call(this);\n")
					done()
				).done()

			it 'should return an error', (done) ->
				Compiler.compileFile(dir + '/coffee/error.coffee').fail( (err) ->
					expect(err).to.be.an.instanceof(Error)
					done()
				).done()

		describe 'json', ->
			it 'should return compiled json file from compileFile method', (done) ->
				Compiler.compileFile(dir + '/json/simple.json').then( (data) ->
					expect(data).to.be.equal('(function() {\nreturn {\n\t"message": "hello"\n}\n}).call(this);\n')
					done()
				).done()

		describe 'ts', ->
			it 'should return compiled ts file from compileFile method', (done) ->
				Compiler.compileFile(dir + '/ts/simple.ts').then( (data) ->
					expect(data).to.be.equal("var message = 'hello';\n")
					done()
				).done()

		describe 'less', ->
			it 'should return compiled less file from compileFile method', (done) ->
				Compiler.compileFile(dir + '/less/simple.less').then( (data) ->
					expect(data).to.be.equal('body {\n  color: #ff0000;\n}\n')
					done()
				).done()

			it 'should return an error for bad less file', (done) ->
				Compiler.compileFile(dir + '/less/error.less').fail( (err) ->
					expect(err).to.be.an.instanceof(Error)
					done()
				).done()

		describe 'scss', ->
			it 'should return compiled scss file from compileFile method', (done) ->
				Compiler.compileFile(dir + '/scss/simple.scss').then( (data) ->
					expect(data).to.be.equal('body {\n  color: red; }\n')
					done()
				).done()

			it 'should return error for bad file', (done) ->
				Compiler.compileFile(dir + '/scss/error.scss').fail( (err) ->
					expect(err).to.be.an.instanceof(Error)
					done()
				).done()

		describe 'styl', ->
			it 'should return compiled styl file from compileFile method', (done) ->
				Compiler.compileFile(dir + '/styl/simple.styl').then( (data) ->
					expect(data).to.be.equal('body {\n  color: #f00;\n}\n')
					done()
				).done()

	describe '#parseDependents()', ->
		it 'should return list of files from fs-finder', ->
			expect(Compiler.parseDependents([
				dir + '/less/simple.less'
				dir + '/scss/*.<scss$>'
				dir + '/styl/<(import|simple)\.styl$>'
				'http://www.my-site.com/style.less'
			])).to.be.eql([
				dir + '/less/simple.less'
				dir + '/scss/error.scss'
				dir + '/scss/import.scss'
				dir + '/scss/simple.scss'
				dir + '/styl/import.styl'
				dir + '/styl/simple.styl'
				'http://www.my-site.com/style.less'
			])