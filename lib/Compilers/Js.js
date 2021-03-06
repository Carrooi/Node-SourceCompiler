// Generated by CoffeeScript 1.6.3
(function() {
  var Compiler, Js, Q, _ref,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Q = require('q');

  Compiler = require('./Compiler');

  Js = (function(_super) {
    __extends(Js, _super);

    function Js() {
      _ref = Js.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    Js.prototype.getMinifier = function() {
      return 'js';
    };

    Js.prototype.parse = function(data, options) {
      if (options == null) {
        options = {};
      }
      return Q.resolve(data);
    };

    return Js;

  })(Compiler);

  module.exports = Js;

}).call(this);
