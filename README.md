# Source compiler

This package allows you to simply use some transcompilers with just one API and simple error handling.

Source-Compiler uses [Q](https://npmjs.org/package/q) promise package.

## Installation

```
$ npm install source-compiler
```

## Supported files

### Javascript

* js (plain javascript)
* coffee-script ([link](https://npmjs.org/package/coffee-script))
* json (wrap automatically into anonymous function)
* typescript ([link](https://npmjs.org/package/typescript))

### CSS frameworks

* less ([link](https://npmjs.org/package/less))
* sass (scss, [link](https://npmjs.org/package/node-sass))
* stylus ([link](https://npmjs.org/package/stylus))

### Templates

* eco ([link](https://github.com/sstephenson/eco))

## Usage

Bellow is example of already loaded less style compiled into css (OK, there is nothing to compile ;-) )

```
var Compiler = require('source-compiler');

Compiler.compile('less', 'body { color: red; }').then(function(result) {
	console.log(result);		// output: body {\n  color: red;\n}\n
});
```

In the same way, other languages will work.

### Styles with imports

If there is any import in your style, you will have to also set path to the original file. Then it's framework will know,
where to look for other imports.

See section `options`

### Typescript

Every time when you want to use typescript, you will need to set also path, otherwise error will be return.

See section `options`

Parsing typescript is really slow, this is because of there is no public API in typescript for other developers. Source
compiler needs to use some workarounds because of this.

## Options

* path: path to the original source file (if you can, just set it)
* minify: boolean option, if it is true, then result file will be compressed
	+ css styles: ([clean-css](https://npmjs.org/package/clean-css))
	+ js: ([uglify-js](https://npmjs.org/package/uglify-js))
	+ html: ([html-minifier](https://npmjs.org/package/html-minifier))
* precompile: some frameworks can just prepare your code for another usage without framework itself (eg. in browser). This options is for templates
* jquerify: this option is also for templates and it wrap automatically result template into jQuery function
* data: again for templates. This is an object with your variables passed to templates
* dependents: array of dependent files (used for style caching - see below)

```
Compiler.compile('less', 'body { color: red; }', {
	path: '/var/path/to/the/original/file.less',
	minify: true
}).then(function(result) {
	console.log(result);		// output: body {\n  color: red;\n}\n
});
```

## Parsing files

Parsing files can be even more simple, because source-compiler will determinate type and set path automatically.

```
Compiler.compileFile('/var/path/to/the/original/file.less', {minify: true}).then(function(result) {
	console.log(result);
});
```

## Remote files

You can also load remote files using HTTP or HTTPS protocol.

```
Compiler.compileFile('http://my.website.com/some_file.coffee').then(function(result) {
	console.log(result);
});
```

## Handling errors

All error messages should be parsed into one type, so you can easily work with them.

```
Compiler.compile('scss', '{',).than(function(result) {

}, function(err) {
	console.log(err);
});
```

or just look at the error

```
Compiler.compile('scss', '{',).fail(function(err) {
	console.log(err);
});
```

### List of exceptions

* `Exceptions/CompileException`: Returned on errors while compile time (eg. unknown path for imports in css frameworks)
* `Exceptions/HttpGetException`: Returned on error while loading file from remote source
* `Exceptions/InvalidArgumentException`: Now only when type to compile is not supported
* `Exceptions/SyntaxException`: Returned when there is some syntax error in your file

### Properties of compile and syntax exception

* `filename`: Path to file with error
* `line`: Number of line where your error is
* `column`: Number of char position in line with error
* `lastLine`: Only for coffee-script
* `lastColumn`: Only for coffee-script

### Example of working with exceptions

```
var SyntaxException = require('source-compiler/Exceptions/SyntaxException');
var CompileException = require('source-compiler/Exceptions/CompileException');

Compiler.compileFile('/var/data/path/to/some/file.coffee').fail(function(err) {
	if (err instanceof SyntaxException) {

	} else if (err instanceof CompileException) {

	} else {

	}
});
```

## Caching

You can turn on cache, so when files are not changed, they will be loaded from cache. Source compiler uses [cache-storage](https://npmjs.org/package/cache-storage)
module.

Caching works only for compileFile method and for files which are not loaded from remote host.

```
Compiler.setCache('/path/to/cache/directory');
```

Now every files will be parsed only once after change and then will be loaded from cache. The only difference is with styles.

If you also want to cache styles, you have to set dependent files (files which you are importing in your styles). If these
files are not provided, then when you change some imported files, source-compiler will not recompile your styles, but use
old version from cache.

```
Compiler.compileFile('/var/path/to/the/original/file.less', {dependents: ['/var/path/to/the/original/other.less']}).then(function(data) {

});
```

You can see, that dependents option is just array of dependent files. If you have not got any imports in styles, set just
empty array. If you will not, cache will be turned off for this style file.

When you have got many dependent files, you can use asterisk or regular expression for dependents options. This feature
uses [fs-finder](https://npmjs.org/package/fs-finder) package.

```
Compiler.compileFile('/var/path/to/the/original/file.less', {dependents: ['/var/path/to/the/original/*.less']}).then(function(data) {

});

// or with some regex

Compiler.compileFile('/var/path/to/the/original/file.less', {dependents: ['/var/path/to/the/original/<[a-z]+\.less$>']}).then(function(data) {

});
```

## Tests

```
$ npm test
```

## Changelog

* 2.0.1
	+ Syntax error in precompiled and jquerified eco templates

* 2.0.0
	+ Better readme
	+ Added some tests
	+ Updated dependencies
	+ Refactoring whole Compiler (each compiler has got own class)
	+ Added custom exception classes
	+ Much better error exceptions
	+ Support for minifiing html from eco templates (thanks to [html-minifier](https://npmjs.org/package/html-minifier))

* 1.3.4
	+ Rewritten tests
	+ Missing error messages from compileFile method
	+ Some typos in readme

* 1.3.3
	+ Bug in wrapping js files

* 1.3.2
	+ Bug in loading remote files

* 1.3.1
	+ JS files are automatically wrapped into function

* 1.3.0
	+ Support for remote (HTTP/HTTPS) files

* 1.2.0
	+ Added support for caching files

* 1.1.1
	+ Added support for plain javascript

* 1.1.0
	+ Increased timeout for tests (because of typescript)
	+ Another test reporter
	+ Support for ECO templates
	+ jquerifing templates
	+ precompile templates

* 1.0.0
	+ Initial version