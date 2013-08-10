(function () {

	var should = require('should');
	var fs = require('fs');

	var Compiler = require('../lib/Compiler');

	var dir = __dirname + '/data';
	var files = {
		simple: {
			coffee: fs.readFileSync(dir + '/coffee/simple.coffee', {encoding: 'utf-8'}),
			json: fs.readFileSync(dir + '/json/simple.json', {encoding: 'utf-8'}),
			ts: fs.readFileSync(dir + '/ts/simple.ts', {encoding: 'utf-8'}),
			less: fs.readFileSync(dir + '/less/simple.less', {encoding: 'utf-8'}),
			scss: fs.readFileSync(dir + '/scss/simple.scss', {encoding: 'utf-8'}),
			styl: fs.readFileSync(dir + '/styl/simple.styl', {encoding: 'utf-8'}),
			eco: fs.readFileSync(dir + '/eco/simple.eco', {encoding: 'utf-8'})
		},
		error: {
			coffee: fs.readFileSync(dir + '/coffee/error.coffee', {encoding: 'utf-8'}),
			json: fs.readFileSync(dir + '/json/error.json', {encoding: 'utf-8'}),
			ts: fs.readFileSync(dir + '/ts/error.ts', {encoding: 'utf-8'}),
			less: fs.readFileSync(dir + '/less/error.less', {encoding: 'utf-8'}),
			scss: fs.readFileSync(dir + '/scss/error.scss', {encoding: 'utf-8'}),
			styl: fs.readFileSync(dir + '/styl/error.styl', {encoding: 'utf-8'})
		},
		imports: {
			less: fs.readFileSync(dir + '/less/import.less', {encoding: 'utf-8'}),
			scss: fs.readFileSync(dir + '/scss/import.scss', {encoding: 'utf-8'}),
			styl: fs.readFileSync(dir + '/styl/import.styl', {encoding: 'utf-8'})
		},
		results: {
			coffee: "(function() {\n  var message;\n\n  message = 'hello';\n\n}).call(this);\n",
			json: '(function() {\nreturn {\n\t"message": "hello"\n}\n}).call(this);\n',
			ts: "var message = 'hello';\r\n",
			less: 'body {\n  color: #ff0000;\n}\n',
			scss: 'body {\n  color: red; }\n',
			styl: 'body {\n  color: #f00;\n}\n',
			eco: {
				simple: '<span>hello</span>\n<span>Bye</span>',
				jquerify: "(function() {\n$('<span>hello</span>' +\n'<span>Bye</span>');\n}).call(this);",
				jquerifyMinify: '!function(){$("<span>hello</span><span>Bye</span>")}.call(this);'
			}
		},
		minified: {
			css: 'body{color:red}',
			js: '!function(){var l;l="hello"}.call(this);',
			json: '!function(){return{message:"hello"}}.call(this);',
			ts: 'var message="hello";'
		}
	};

	describe('Compiler', function() {

		describe('#isSupported()', function() {
			it('should return true', function() {
				Compiler.isSupported('less').should.be.true;
			});

			it('should return false', function() {
				Compiler.isSupported('jpg').should.be.false;
			});
		});

		describe('#getType()', function() {
			it('should return type of css framework from file', function() {
				Compiler.getType('/var/data/css/variables.less').should.be.equal('less');
			});
		});

		describe('#compile()', function() {

			/************************************ BASE ***********************************/

			/**
			 * NOT SUPPORTED FRAMEWORK
			 */

			it('should return error when framework type is not supported', function(done) {
				Compiler.compile('jpg', '').fail(function(err) {
					err.should.be.an.instanceOf(Error);
					done();
				}).done();
			});

			/********************************* JAVASCRIPT ********************************/

			/**
			 * SIMPLE JS FILES
			 */

			it('should return compiled coffee file', function(done) {
				Compiler.compile('coffee', files.simple.coffee).then(function(data) {
					data.should.be.equal(files.results.coffee);
					done();
				}).done();
			});

			it('should return compiled json file', function(done) {
				Compiler.compile('json', files.simple.json).then(function(data) {
					data.should.be.equal(files.results.json);
					done();
				}).done();
			});

			it('should return compiled ts file', function(done) {		// Path must be defined
				Compiler.compile('ts', files.simple.ts, {path: dir + '/ts/simple.ts'}).then(function(data) {
					data.should.be.equal(files.results.ts);
					done();
				}).done();
			});

			/**
			 * SIMPLE JS FILES WITH ERRORS
			 */

			it('should return error in coffee', function(done) {
				Compiler.compile('coffee', files.error.coffee).fail(function(err) {
					err.should.be.an.instanceOf(Error);
					done();
				}).done();
			});

			it('should return error in ts if path is not defined', function(done) {
				Compiler.compile('ts', files.error.simple).fail(function(err) {
					err.should.be.an.instanceOf(Error);
					done();
				}).done();
			});

			/**
			 * SIMPLE JS FILES WITH ERRORS AND BETTER ERROR MESSAGES
			 */

			it('should return error in coffee with information about source file', function(done) {
				Compiler.compile('coffee', files.error.coffee, {path: dir + '/coffee/error.coffee'}).fail(function(err) {
					err.should.be.an.instanceOf(Error);
					done();
				}).done();
			});

			/**
			 * MINIFY JS
			 */

			it('should return minified coffee file', function(done) {
				Compiler.compile('coffee', files.simple.coffee, {minify: true}).then(function(data) {
					data.should.be.equal(files.minified.js);
					done();
				}).done();
			});

			it('should return minified json file', function(done) {
				Compiler.compile('json', files.simple.json, {minify: true}).then(function(data) {
					data.should.be.equal(files.minified.json);
					done();
				}).done();
			});

			it('should return minified ts file', function(done) {
				Compiler.compile('ts', files.simple.ts, {path: dir + '/ts/simple.ts', minify: true}).then(function(data) {
					data.should.be.equal(files.minified.ts);
					done();
				}).done();
			});

			/**
			 * SIMPLE JS FILES COMPILED FROM FILES
			 */

			it('should return compiled coffee file from compileFile method', function(done) {
				Compiler.compileFile(dir + '/coffee/simple.coffee').then(function(data) {
					data.should.be.equal(files.results.coffee);
					done();
				}).done();
			});

			it('should return compiled json file from compileFile method', function(done) {
				Compiler.compileFile(dir + '/json/simple.json').then(function(data) {
					data.should.be.equal(files.results.json);
					done();
				}).done();
			});

			it('should return compiled ts file from compileFile method', function(done) {
				Compiler.compileFile(dir + '/ts/simple.ts').then(function(data) {
					data.should.be.equal(files.results.ts);
					done();
				}).done();
			});

			it('should return compiled coffee file from remote repository', function(done) {
				Compiler.compileFile('https://raw.github.com/sakren/node-source-compiler/master/test/data/coffee/simple.coffee').then(function(data) {
					data.should.be.equal(files.results.coffee);
					done();
				}).done();
			});

			/********************************* CSS FILES *********************************/

			/**
			 * SIMPLE CSS FILES
			 */

			it('should return compiled less file', function(done) {
				Compiler.compile('less', files.simple.less).then(function(data) {
					data.should.be.equal(files.results.less);
					done();
				}).done();
			});

			it('should return compiled scss file', function(done) {
				Compiler.compile('scss', files.simple.scss).then(function(data) {
					data.should.be.equal(files.results.scss);
					done();
				}).done();
			});

			it('should return compiled styl file', function(done) {
				Compiler.compile('styl', files.simple.styl).then(function(data) {
					data.should.be.equal(files.results.styl);
					done();
				}).done();
			});

			/**
			 * SIMPLE CSS FILES WITH ERRORS
			 */

			it('should return error in less', function(done) {
				Compiler.compile('less', files.error.less).fail(function(err) {
					err.should.be.an.instanceOf(Error);
					done();
				}).done();
			});

			it('should return error in scss', function(done) {
				Compiler.compile('scss', files.error.scss).fail(function(err) {
					err.should.be.an.instanceOf(Error);
					done();
				}).done();
			});

			it('should return error in styl', function(done) {
				Compiler.compile('styl', files.error.styl).fail(function(err) {
					err.should.be.an.instanceOf(Error);
					done();
				}).done();
			});

			/**
			 * SIMPLE CSS FILES WITH ERRORS AND BETTER ERROR MESSAGES
			 */

			it('should return error in less with information about source file', function(done) {
				Compiler.compile('less', files.error.less, {path: dir + '/less/error.less'}).fail(function(err) {
					err.should.be.an.instanceOf(Error);
					done();
				}).done();
			});

			it('should return error in scss with information about source file', function(done) {
				Compiler.compile('scss', files.error.less, {path: dir + '/scss/error.scss'}).fail(function(err) {
					err.should.be.an.instanceOf(Error);
					done();
				}).done();
			});

			it('should return error in styl with information about source file', function(done) {
				Compiler.compile('styl', files.error.less, {path: dir + '/styl/error.styl'}).fail(function(err) {
					err.should.be.an.instanceOf(Error);
					done();
				}).done();
			});

			/**
			 * CSS FILES WITH IMPORTS
			 */

			it('should return compiled less file with imports', function(done) {
				Compiler.compile('less', files.imports.less, {path: dir + '/less/import.less'}).then(function(data) {
					data.should.be.equal(files.results.less);
					done();
				}).done();
			});

			it('should return compiled scss file with imports', function(done) {
				Compiler.compile('scss', files.imports.scss, {path: dir + '/scss/import.scss'}).then(function(data) {
					data.should.be.equal(files.results.scss);
					done();
				}).done();
			});

			it('should return compiled styl file with imports', function(done) {
				Compiler.compile('styl', files.imports.styl, {path: dir + '/styl/import.styl'}).then(function(data) {
					data.should.be.equal(files.results.styl);
					done();
				}).done();
			});

			/**
			 * CSS FILES WITH IMPORTS BUT WITHOUT PATH DEFINED
			 */

			it('should return error if in less are imports and path is not defined', function(done) {
				Compiler.compile('less', files.imports.less).fail(function(err) {
					err.should.be.an.instanceOf(Error);
					done();
				}).done();
			});

			it('should return error if in scss are imports and path is not defined', function(done) {
				Compiler.compile('scss', files.imports.scss).fail(function(err) {
					err.should.be.an.instanceOf(Error);
					done();
				}).done();
			});

			it('should return error if in styl are imports and path is not defined', function(done) {
				Compiler.compile('styl', files.imports.styl).fail(function(err) {
					err.should.be.an.instanceOf(Error);
					done();
				}).done();
			});

			/**
			 * MINIFY CSS
			 */

			it('should return minified less styles', function(done) {
				Compiler.compile('less', files.simple.less, {minify: true}).then(function(data) {
					data.should.be.equal(files.minified.css);
					done();
				}).done();
			});

			it('should return minified scss styles', function(done) {
				Compiler.compile('scss', files.simple.scss, {minify: true}).then(function(data) {
					data.should.be.equal(files.minified.css);
					done();
				}).done();
			});

			it('should return minified styl styles', function(done) {
				Compiler.compile('styl', files.simple.styl, {minify: true}).then(function(data) {
					data.should.be.equal(files.minified.css);
					done();
				}).done();
			});

			/**
			 * SIMPLE CSS FILES COMPILED FROM FILES
			 */

			it('should return compiled less file from compileFile method', function(done) {
				Compiler.compileFile(dir + '/less/simple.less').then(function(data) {
					data.should.be.equal(files.results.less);
					done();
				}).done();
			});

			it('should return compiled scss file from compileFile method', function(done) {
				Compiler.compileFile(dir + '/scss/simple.scss').then(function(data) {
					data.should.be.equal(files.results.scss);
					done();
				}).done();
			});

			it('should return compiled styl file from compileFile method', function(done) {
				Compiler.compileFile(dir + '/styl/simple.styl').then(function(data) {
					data.should.be.equal(files.results.styl);
					done();
				}).done();
			});

			/********************************* OTHER ********************************/

			/**
			 * SIMPLE OTHER FILES
			 */

			it('should return compiled eco file', function(done) {
				Compiler.compile('eco', files.simple.eco, {data: {message: 'hello'}}).then(function(data) {
					data.should.be.equal(files.results.eco.simple);
					done();
				}).done();
			});

			/**
			 * JQUERIFY RESULT
			 */

			it('should return compiled and jquerified eco file', function(done) {
				Compiler.compile('eco', files.simple.eco, {jquerify: true, data: {message: 'hello'}}).then(function(data) {
					data.should.be.equal(files.results.eco.jquerify);
					done();
				}).done();
			});

			/**
			 * MINIFY JQUERIFY RESULT
			 */

			it('should return compiled, minified and jquerified eco file', function(done) {
				Compiler.compile('eco', files.simple.eco, {jquerify: true, minify: true, data: {message: 'hello'}}).then(function(data) {
					data.should.be.equal(files.results.eco.jquerifyMinify);
					done();
				}).done();
			});

			/**
			 * MINIFY PRECOMPILED RESULT - ERROR
			 */

			it('should return error if you try to minify precompiled eco file', function(done) {
				Compiler.compile('eco', files.simple.eco, {precompile: true, minify: true}).fail(function(err) {
					err.should.be.an.instanceOf(Error);
					done();
				}).done();
			});

			/**
			 * MINIFY HTML TEMPLATE - ERROR
			 */

			it('should return error if you try to minify clean template', function(done) {
				Compiler.compile('eco', files.simple.eco, {minify: true, data: {message: 'hello'}}).fail(function(err) {
					err.should.be.an.instanceOf(Error);
					done();
				}).done();
			});

		});

		describe('#setCache()', function() {

			beforeEach(function() {
				Compiler.setCache(__dirname + '/data/cache');
			})

			afterEach(function() {
				Compiler.cache = null;
				var file = __dirname + '/data/cache/__' + Compiler.CACHE_NAMESPACE + '.json'
				if (fs.existsSync(file)) {
					fs.unlinkSync(file);
				}
			});

			it('should be null when coffee file is not in cache', function() {
				should.not.exists(Compiler.cache.load(dir + '/coffee/simple.coffee'));
			});

			it('should save compiled coffee file to cache', function(done) {
				Compiler.compileFile(dir + '/coffee/simple.coffee').then(function(data) {
					Compiler.cache.load(dir + '/coffee/simple.coffee').should.be.equal(files.results.coffee);
					done();
				}).done();
			});

			it('should load compiled coffee file from cache', function(done) {
				Compiler.compileFile(dir + '/coffee/simple.coffee').then(function(data) {
					Compiler.compileFile(dir + '/coffee/simple.coffee').then(function(data) {
						data.should.be.equal(files.results.coffee);
						done();
					}).done();
				}).done();
			});

			it('should not save less file to cache', function(done) {
				Compiler.compileFile(dir + '/less/simple.less').then(function(data) {
					should.not.exists(Compiler.cache.load(dir + '/less/simple.less'));
					done();
				}).done();
			});

			it('should save less file to cache if dependents are defined', function(done) {
				Compiler.compileFile(dir + '/less/simple.less', {dependents: []}).then(function(data) {
					Compiler.cache.load(dir + '/less/simple.less').should.be.equal(files.results.less);
					done();
				}).done();
			});

		});

		describe('#_parseDependents()', function() {

			it('should return list of files from fs-finder', function() {
				Compiler._parseDependents([
					dir + '/less/simple.less',
					dir + '/scss/*.<scss$>',
					dir + '/styl/<(import|simple)\.styl$>'
				]).should.be.eql([
					dir + '/less/simple.less',
					dir + '/scss/error.scss',
					dir + '/scss/import.scss',
					dir + '/scss/simple.scss',
					dir + '/styl/import.styl',
					dir + '/styl/simple.styl'
				]);
			});

		});

	});

})();