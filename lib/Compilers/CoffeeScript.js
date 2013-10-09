// Generated by CoffeeScript 1.6.3
(function() {
  var CoffeeScript, CompileException, Compiler, Q, SyntaxException, coffee, _ref,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Q = require('q');

  coffee = require('coffee-script');

  Compiler = require('./Compiler');

  CompileException = require('../Exceptions/CompileException');

  SyntaxException = require('../Exceptions/SyntaxException');

  CoffeeScript = (function(_super) {
    __extends(CoffeeScript, _super);

    function CoffeeScript() {
      _ref = CoffeeScript.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    CoffeeScript.prototype.getMinifier = function() {
      return 'uglify';
    };

    CoffeeScript.prototype.parse = function(data, options) {
      var deferred, err, setup;
      if (options == null) {
        options = {};
      }
      setup = {
        literate: false
      };
      if (options.path !== null) {
        setup.filename = options.path;
      }
      deferred = Q.defer();
      try {
        deferred.resolve(coffee.compile(data, setup));
      } catch (_error) {
        err = _error;
        deferred.reject(this.parseError(err, options.path));
      }
      return deferred.promise;
    };

    CoffeeScript.prototype.parseError = function(error, _path) {
      var e;
      if (_path == null) {
        _path = null;
      }
      if (error instanceof SyntaxError) {
        e = new SyntaxException(error.message);
        e.filename = _path;
        e.line = error.location.first_line;
        e.column = error.location.first_column;
        e.lastLine = error.location.last_line;
        e.lastColumn = error.location.last_column;
      } else {
        e = new CompileException(error.message);
        e.filename = _path;
      }
      return e;
    };

    return CoffeeScript;

  })(Compiler);

  module.exports = CoffeeScript;

}).call(this);