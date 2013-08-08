# Source compiler

This package allows you to simply use some transcompilers with just one API and simple error handling.

Source-Compiler uses [Q](https://npmjs.org/package/q) promise package.

## Changelog

Changelog is in the bottom of this readme

## Supported files

### Javascript

* js (plain javascript)
* coffee-script ([link](https://npmjs.org/package/coffee-script))
* json (wrap automatically into annonymouse function)
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

Every time when you want to use typescript, you will need to set also path, othervise error will be returns.

See section `options`

Parsing typescript is really slow, this is because of there is no public API in typescript for other developers. Source
compiler needs to use some workarounds because of this.

## Options

* path: path to the original source file (if you can, just set it)
* minify: boolean option, if it is true, then result file will be compressed
	+ css styles: ([clean-css](https://npmjs.org/package/clean-css))
	+ js: ([uglify-js](https://npmjs.org/package/uglify-js))
* precompile: some frameworks can just prepare your code for another usage without framework itself (eg. in browser). This options is for templates
* jquerify: this option is also for templates and it wrap automatically result template into jQuery function
* data: again for templates. This is an object with your variables passed to templates

```
Compiler.compile('less', 'body { color: red; }', {
	path: '/var/path/to/the/original/file.less',
	minify: true
}).then(function(result) {
	console.log(result);		// output: body {\n  color: red;\n}\n
});
```

## ECO templates

Unfortenatelly now minifiing is supported only for jquerified templates.

## Parsing files

Parsing files can be even more simple, because source-compiler will determinate type and set path automatically.

```
Compiler.compileFile('/var/path/to/the/original/file.less', {minify: true}).then(function(result) {
	console.log(result);
});
```

## Handling errors

All error messages should be parsed into one type, so you can easilly work with them. Errors are [Error](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Error) instances.

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

## Changelog

* 1.1.1
	+ Added support for plain javascript

* 1.1.0
	+ Inceresed timeout for tests (because of typescript)
	+ Another test reporter
	+ Support for ECO templates
	+ jquerifing templates
	+ precompile templates

* 1.0.0
	+ Initial version