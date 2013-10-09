// Generated by CoffeeScript 1.6.3
(function() {
  var AbstractException, SyntaxException, util;

  util = require('util');

  AbstractException = require('./AbstractException');

  SyntaxException = function(message) {
    return SyntaxException.super_.call(this, message, this.constructor);
  };

  util.inherits(SyntaxException, AbstractException);

  SyntaxException.prototype.name = 'Syntax Exception';

  module.exports = SyntaxException;

}).call(this);