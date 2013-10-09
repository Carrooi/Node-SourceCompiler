// Generated by CoffeeScript 1.6.3
(function() {
  var CompileException, Compiler, InvalidArgumentException, SyntaxException, dir, expect, fs, loadFile, path;

  expect = require('chai').expect;

  fs = require('fs');

  path = require('path');

  Compiler = require('../../lib/Compiler');

  InvalidArgumentException = require('../../lib/Exceptions/InvalidArgumentException');

  CompileException = require('../../lib/Exceptions/CompileException');

  SyntaxException = require('../../lib/Exceptions/SyntaxException');

  dir = path.resolve(__dirname + '/../data');

  loadFile = function(_path) {
    return fs.readFileSync(dir + '/' + _path, {
      encoding: 'utf8'
    });
  };

  describe('Compiler', function() {
    describe('#hasCompiler()', function() {
      it('should return true', function() {
        return expect(Compiler.hasCompiler('less')).to.be["true"];
      });
      return it('should return false', function() {
        return expect(Compiler.hasCompiler('jpg')).to.be["false"];
      });
    });
    describe('#getType()', function() {
      return it('should return type of css framework from file', function() {
        return expect(Compiler.getType('/var/data/css/variables.less')).to.be.equal('less');
      });
    });
    describe('#compile()', function() {
      it('should return error when framework type is not supported', function(done) {
        return Compiler.compile('jpg', '').fail(function(err) {
          expect(err).to.be.an["instanceof"](InvalidArgumentException);
          expect(err.message).to.be.equal('Type jpg is not supported.');
          return done();
        }).done();
      });
      describe('coffee', function() {
        it('should return compiled coffee file', function(done) {
          return Compiler.compile('coffee', loadFile('coffee/simple.coffee')).then(function(data) {
            expect(data).to.be.equal("(function() {\n  var message;\n\n  message = 'hello';\n\n}).call(this);\n");
            return done();
          }).done();
        });
        it('should return error in coffee', function(done) {
          return Compiler.compile('coffee', loadFile('coffee/error.coffee')).fail(function(err) {
            expect(err).to.be.an["instanceof"](SyntaxException);
            expect(err.message).to.be.equal('unexpected COMPARE');
            expect(err.filename).to.be["null"];
            return done();
          }).done();
        });
        it('should return another error in coffee', function(done) {
          return Compiler.compile('coffee', loadFile('coffee/error2.coffee')).fail(function(err) {
            expect(err).to.be.an["instanceof"](SyntaxException);
            expect(err.message).to.be.equal('unexpected =');
            expect(err.filename).to.be["null"];
            expect(err.line).to.be.equal(12);
            expect(err.column).to.be.equal(7);
            return done();
          }).done();
        });
        it('should return error in coffee with information about source file', function(done) {
          return Compiler.compile('coffee', loadFile('coffee/error.coffee'), {
            path: dir + '/coffee/error.coffee'
          }).fail(function(err) {
            expect(err).to.be.an["instanceof"](SyntaxException);
            expect(err.message).to.be.equal('unexpected COMPARE');
            expect(err.filename).to.be.equal(dir + '/coffee/error.coffee');
            return done();
          }).done();
        });
        return it('should return minified coffee file', function(done) {
          return Compiler.compile('coffee', loadFile('coffee/simple.coffee'), {
            minify: true
          }).then(function(data) {
            expect(data).to.be.equal('(function(){var l;l="hello"}).call(this);');
            return done();
          }).done();
        });
      });
      describe('json', function() {
        it('should return compiled json file', function(done) {
          return Compiler.compile('json', loadFile('json/simple.json')).then(function(data) {
            expect(data).to.be.equal('(function() {\nreturn {\n\t"message": "hello"\n}\n}).call(this);\n');
            return done();
          }).done();
        });
        return it('should return minified json file', function(done) {
          return Compiler.compile('json', loadFile('json/simple.json'), {
            minify: true
          }).then(function(data) {
            expect(data).to.be.equal('(function(){return{message:"hello"}}).call(this);');
            return done();
          }).done();
        });
      });
      describe('js', function() {
        return it('should return compiled js file', function(done) {
          return Compiler.compile('js', loadFile('js/simple.js')).then(function(data) {
            expect(data).to.be.equal("var message = 'hello';");
            return done();
          }).done();
        });
      });
      describe('ts', function() {
        it('should return compiled ts file', function(done) {
          return Compiler.compile('ts', loadFile('ts/simple.ts'), {
            path: dir + '/ts/simple.ts'
          }).then(function(data) {
            expect(data).to.be.equal("var message = 'hello';\n");
            return done();
          }).done();
        });
        it('should return error in ts if path is not defined', function(done) {
          return Compiler.compile('ts', loadFile('ts/simple.ts')).fail(function(err) {
            expect(err).to.be.an["instanceof"](CompileException);
            expect(err.message).to.be.equal('You have to set path for compiling typescript.');
            return done();
          }).done();
        });
        it('should return error for bad file', function(done) {
          return Compiler.compile('ts', loadFile('ts/error.ts'), {
            path: dir + '/ts/error.ts'
          }).fail(function(err) {
            expect(err).to.be.an["instanceof"](SyntaxException);
            expect(err.message).to.have.string('Unexpected token');
            expect(err.filename).to.be.equal(dir + '/ts/error.ts');
            expect(err.line).to.be.equal(1);
            expect(err.column).to.be.equal(1);
            expect(err.code).to.be.equal(1008);
            return done();
          }).done();
        });
        it('should return another error for bad file', function(done) {
          return Compiler.compile('ts', loadFile('ts/error2.ts'), {
            path: dir + '/ts/error2.ts'
          }).fail(function(err) {
            expect(err).to.be.an["instanceof"](SyntaxException);
            expect(err.filename).to.be.equal(dir + '/ts/error2.ts');
            expect(err.line).to.be.equal(7);
            expect(err.column).to.be.equal(35);
            expect(err.code).to.be.equal(1005);
            return done();
          }).done();
        });
        return it('should return minified ts file', function(done) {
          return Compiler.compile('ts', loadFile('ts/simple.ts'), {
            path: dir + '/ts/simple.ts',
            minify: true
          }).then(function(data) {
            expect(data).to.be.equal('var message="hello";');
            return done();
          }).done();
        });
      });
      describe('less', function() {
        it('should return compiled less file', function(done) {
          return Compiler.compile('less', loadFile('less/simple.less')).then(function(data) {
            expect(data).to.be.equal('body {\n  color: #ff0000;\n}\n');
            return done();
          }).done();
        });
        it('should return error in less', function(done) {
          return Compiler.compile('less', loadFile('less/error.less')).fail(function(err) {
            expect(err).to.be.an["instanceof"](SyntaxException);
            expect(err.message).to.be.equal('missing closing `}`');
            expect(err.filename).to.be["null"];
            expect(err.line).to.be.equal(1);
            expect(err.column).to.be.equal(0);
            expect(err.type).to.be.equal('Parse');
            return done();
          }).done();
        });
        it('should return another error', function(done) {
          return Compiler.compile('less', 'body {color: @red;}').fail(function(err) {
            expect(err).to.be.an["instanceof"](SyntaxException);
            expect(err.message).to.be.equal('variable @red is undefined');
            expect(err.filename).to.be["null"];
            expect(err.line).to.be.equal(1);
            expect(err.column).to.be.equal(13);
            expect(err.type).to.be.equal('Name');
            return done();
          }).done();
        });
        it('should return error in less with information about source file', function(done) {
          return Compiler.compile('less', loadFile('less/error.less'), {
            path: dir + '/less/error.less'
          }).fail(function(err) {
            expect(err).to.be.an["instanceof"](SyntaxException);
            expect(err.message).to.be.equal('missing closing `}`');
            expect(err.filename).to.be.equal(dir + '/less/error.less');
            expect(err.line).to.be.equal(1);
            expect(err.column).to.be.equal(0);
            expect(err.type).to.be.equal('Parse');
            return done();
          }).done();
        });
        it('should return compiled less file with imports', function(done) {
          return Compiler.compile('less', loadFile('less/import.less'), {
            path: dir + '/less/import.less'
          }).then(function(data) {
            expect(data).to.be.equal('body {\n  color: #ff0000;\n}\n');
            return done();
          }).done();
        });
        it('should return error if in less are imports and path is not defined', function(done) {
          return Compiler.compile('less', loadFile('less/import.less')).fail(function(err) {
            expect(err).to.be.an["instanceof"](SyntaxException);
            expect(err.message).to.be.equal("\'simple.less\' wasn\'t found");
            expect(err.filename).to.be["null"];
            expect(err.line).to.be.equal(1);
            expect(err.column).to.be.equal(0);
            expect(err.type).to.be.equal('File');
            return done();
          }).done();
        });
        return it('should return minified less styles', function(done) {
          return Compiler.compile('less', loadFile('less/simple.less'), {
            minify: true
          }).then(function(data) {
            expect(data).to.be.equal('body{color:red}');
            return done();
          }).done();
        });
      });
      describe('scss', function() {
        it('should return compiled scss file', function(done) {
          return Compiler.compile('scss', loadFile('scss/simple.scss')).then(function(data) {
            expect(data).to.be.equal('body {\n  color: red; }\n');
            return done();
          }).done();
        });
        it('should return error in scss', function(done) {
          return Compiler.compile('scss', loadFile('scss/error.scss')).fail(function(err) {
            expect(err).to.be.an["instanceof"](SyntaxException);
            expect(err.message).to.have.string('invalid selector');
            expect(err.filename).to.be["null"];
            expect(err.line).to.be.equal(1);
            expect(err.column).to.be["null"];
            return done();
          }).done();
        });
        it('should return error in scss with information about source file', function(done) {
          return Compiler.compile('scss', loadFile('scss/error.scss'), {
            path: dir + '/scss/error.scss'
          }).fail(function(err) {
            expect(err).to.be.an["instanceof"](SyntaxException);
            expect(err.message).to.have.string('invalid selector');
            expect(err.filename).to.be.equal(dir + '/scss/error.scss');
            expect(err.line).to.be.equal(1);
            expect(err.column).to.be["null"];
            return done();
          }).done();
        });
        it('should return compiled scss file with imports', function(done) {
          return Compiler.compile('scss', loadFile('scss/import.scss'), {
            path: dir + '/scss/import.scss'
          }).then(function(data) {
            expect(data).to.be.equal('body {\n  color: red; }\n');
            return done();
          }).done();
        });
        it('should return error if in scss are imports and path is not defined', function(done) {
          return Compiler.compile('scss', loadFile('scss/import.scss')).fail(function(err) {
            expect(err).to.be.an["instanceof"](SyntaxException);
            expect(err.message).to.have.string('file to import not found or unreadable');
            expect(err.filename).to.be["null"];
            expect(err.line).to.be.equal(1);
            expect(err.column).to.be.equal(null);
            return done();
          }).done();
        });
        return it('should return minified scss styles', function(done) {
          return Compiler.compile('scss', loadFile('scss/simple.scss'), {
            minify: true
          }).then(function(data) {
            expect(data).to.be.equal('body{color:red}');
            return done();
          }).done();
        });
      });
      describe('styl', function() {
        it('should return compiled styl file', function(done) {
          return Compiler.compile('styl', loadFile('styl/simple.styl')).then(function(data) {
            expect(data).to.be.equal('body {\n  color: #f00;\n}\n');
            return done();
          }).done();
        });
        it('should return error in styl', function(done) {
          return Compiler.compile('styl', loadFile('styl/error.styl')).fail(function(err) {
            expect(err).to.be.an["instanceof"](SyntaxException);
            expect(err.message).to.have.string('expected "}"');
            expect(err.filename).to.be["null"];
            expect(err.line).to.be.equal(1);
            expect(err.column).to.be["null"];
            return done();
          }).done();
        });
        it('should return error in styl with information about source file', function(done) {
          return Compiler.compile('styl', loadFile('styl/error.styl'), {
            path: dir + '/styl/error.styl'
          }).fail(function(err) {
            expect(err).to.be.an["instanceof"](SyntaxException);
            expect(err.message).to.have.string('expected "}"');
            expect(err.filename).to.be.equal(dir + '/styl/error.styl');
            expect(err.line).to.be.equal(1);
            expect(err.column).to.be["null"];
            return done();
          }).done();
        });
        it('should return compiled styl file with imports', function(done) {
          return Compiler.compile('styl', loadFile('styl/import.styl'), {
            path: dir + '/styl/import.styl'
          }).then(function(data) {
            expect(data).to.be.equal('body {\n  color: #f00;\n}\n');
            return done();
          }).done();
        });
        it('should return error if in styl are imports and path is not defined', function(done) {
          return Compiler.compile('styl', loadFile('styl/import.styl')).fail(function(err) {
            expect(err).to.be.an["instanceof"](SyntaxException);
            expect(err.message).to.be.equal('failed to locate @import file simple.styl');
            expect(err.filename).to.be["null"];
            expect(err.line).to.be.equal(1);
            expect(err.column).to.be["null"];
            return done();
          }).done();
        });
        return it('should return minified styl styles', function(done) {
          return Compiler.compile('styl', loadFile('styl/simple.styl'), {
            minify: true
          }).then(function(data) {
            expect(data).to.be.equal('body{color:red}');
            return done();
          }).done();
        });
      });
      return describe('eco', function() {
        it('should return compiled eco file', function(done) {
          return Compiler.compile('eco', loadFile('eco/simple.eco'), {
            data: {
              message: 'hello'
            }
          }).then(function(data) {
            expect(data).to.be.equal('<span>hello</span>\n<span>Bye</span>');
            return done();
          }).done();
        });
        it('should return compiled and jquerified eco file', function(done) {
          return Compiler.compile('eco', loadFile('eco/simple.eco'), {
            jquerify: true,
            data: {
              message: 'hello'
            }
          }).then(function(data) {
            expect(data).to.be.equal("(function() {\n$('<span>hello</span>' +\n'<span>Bye</span>');\n}).call(this);");
            return done();
          }).done();
        });
        it('should return compiled, minified and jquerified eco file', function(done) {
          return Compiler.compile('eco', loadFile('eco/simple.eco'), {
            jquerify: true,
            minify: true,
            data: {
              message: 'hello'
            }
          }).then(function(data) {
            expect(data).to.be.equal('(function(){$("<span>hello</span><span>Bye</span>")}).call(this);');
            return done();
          }).done();
        });
        it('should return minify and precompiled eco file', function(done) {
          return Compiler.compile('eco', loadFile('eco/simple.eco'), {
            precompile: true,
            minify: true
          }).then(function(data) {
            expect(data).to.be.a('string');
            return done();
          }).done();
        });
        return it('should return error if you try to minify clean template', function(done) {
          return Compiler.compile('eco', loadFile('eco/simple.eco'), {
            minify: true,
            data: {
              message: 'hello'
            }
          }).then(function(data) {
            expect(data).to.be.equal('<span>hello</span><span>Bye</span>');
            return done();
          }).done();
        });
      });
    });
    describe('#compileFile()', function() {
      describe('coffee', function() {
        it('should return compiled coffee file from compileFile method', function(done) {
          return Compiler.compileFile(dir + '/coffee/simple.coffee').then(function(data) {
            expect(data).to.be.equal("(function() {\n  var message;\n\n  message = 'hello';\n\n}).call(this);\n");
            return done();
          }).done();
        });
        it('should return compiled coffee file from remote repository', function(done) {
          return Compiler.compileFile('https://raw.github.com/sakren/node-source-compiler/master/test/data/coffee/simple.coffee').then(function(data) {
            expect(data).to.be.equal("(function() {\n  var message;\n\n  message = 'hello';\n\n}).call(this);\n");
            return done();
          }).done();
        });
        return it('should return an error', function(done) {
          return Compiler.compileFile(dir + '/coffee/error.coffee').fail(function(err) {
            expect(err).to.be.an["instanceof"](SyntaxException);
            expect(err.message).to.be.equal('unexpected COMPARE');
            expect(err.filename).to.be.equal(dir + '/coffee/error.coffee');
            return done();
          }).done();
        });
      });
      describe('json', function() {
        return it('should return compiled json file from compileFile method', function(done) {
          return Compiler.compileFile(dir + '/json/simple.json').then(function(data) {
            expect(data).to.be.equal('(function() {\nreturn {\n\t"message": "hello"\n}\n}).call(this);\n');
            return done();
          }).done();
        });
      });
      describe('ts', function() {
        return it('should return compiled ts file from compileFile method', function(done) {
          return Compiler.compileFile(dir + '/ts/simple.ts').then(function(data) {
            expect(data).to.be.equal("var message = 'hello';\n");
            return done();
          }).done();
        });
      });
      describe('less', function() {
        it('should return compiled less file from compileFile method', function(done) {
          return Compiler.compileFile(dir + '/less/simple.less').then(function(data) {
            expect(data).to.be.equal('body {\n  color: #ff0000;\n}\n');
            return done();
          }).done();
        });
        return it('should return an error for bad less file', function(done) {
          return Compiler.compileFile(dir + '/less/error.less').fail(function(err) {
            expect(err).to.be.an["instanceof"](SyntaxException);
            expect(err.message).to.be.equal('missing closing `}`');
            expect(err.filename).to.be.equal(dir + '/less/error.less');
            expect(err.line).to.be.equal(1);
            expect(err.column).to.be.equal(0);
            expect(err.type).to.be.equal('Parse');
            return done();
          }).done();
        });
      });
      describe('scss', function() {
        it('should return compiled scss file from compileFile method', function(done) {
          return Compiler.compileFile(dir + '/scss/simple.scss').then(function(data) {
            expect(data).to.be.equal('body {\n  color: red; }\n');
            return done();
          }).done();
        });
        return it('should return error for bad file', function(done) {
          return Compiler.compileFile(dir + '/scss/error.scss').fail(function(err) {
            expect(err).to.be.an["instanceof"](SyntaxException);
            expect(err.message).to.have.string('invalid selector');
            expect(err.filename).to.be.equal(dir + '/scss/error.scss');
            expect(err.line).to.be.equal(1);
            expect(err.column).to.be["null"];
            return done();
          }).done();
        });
      });
      return describe('styl', function() {
        return it('should return compiled styl file from compileFile method', function(done) {
          return Compiler.compileFile(dir + '/styl/simple.styl').then(function(data) {
            expect(data).to.be.equal('body {\n  color: #f00;\n}\n');
            return done();
          }).done();
        });
      });
    });
    return describe('#parseDependents()', function() {
      return it('should return list of files from fs-finder', function() {
        return expect(Compiler.parseDependents([dir + '/less/simple.less', dir + '/scss/*.<scss$>', dir + '/styl/<(import|simple)\.styl$>', 'http://www.my-site.com/style.less'])).to.be.eql([dir + '/less/simple.less', dir + '/scss/error.scss', dir + '/scss/import.scss', dir + '/scss/simple.scss', dir + '/styl/import.styl', dir + '/styl/simple.styl', 'http://www.my-site.com/style.less']);
      });
    });
  });

}).call(this);
