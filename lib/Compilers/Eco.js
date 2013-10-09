// Generated by CoffeeScript 1.6.3
(function() {
  var Compiler, Eco, Helpers, InvalidArgumentException, Q, eco, _ref,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Q = require('q');

  eco = require('eco');

  Compiler = require('./Compiler');

  Helpers = require('../Helpers');

  InvalidArgumentException = require('../Exceptions/InvalidArgumentException');

  Eco = (function(_super) {
    __extends(Eco, _super);

    function Eco() {
      _ref = Eco.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    Eco.prototype.getMinifier = function(options) {
      if (options.jquerify === true || options.precompile === true) {
        return 'uglify';
      } else {
        return 'html';
      }
    };

    Eco.prototype.parse = function(data, options) {
      var deferred;
      if (options == null) {
        options = {};
      }
      deferred = Q.defer();
      if (options.precompile === true) {
        data = eco.precompile(data);
        data = data.replace(/\n/g, '\n  ');
        data = '(function() {\n  return ' + data + '\n}).call(this);';
        if (options.jquerify === true) {
          data = Helpers.jquerify.precompiled(data);
        }
      } else {
        data = eco.render(data, options.data);
        if (options.jquerify === true) {
          data = Helpers.jquerify.compiled(data);
        }
      }
      deferred.resolve(data);
      return deferred.promise;
    };

    return Eco;

  })(Compiler);

  module.exports = Eco;

}).call(this);