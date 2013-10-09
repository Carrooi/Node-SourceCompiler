uglify = require 'uglify-js'
cleanCss = require 'clean-css'

class Compiler


	isCachableWithDependencies: -> return false


	getMinifier: ->
		throw new Error 'Method getMinifier is not implemented.'


	parse: (data, options = {}) ->
		throw new Error 'Method parse is not implemented.'


	parseError: (error, path) ->
		throw new Error 'Method parseError is not implemented.'


	@minify:
		uglify: (data) -> return uglify.minify(data, fromString: true).code
		cleanCss: (data) -> return cleanCss.process(data)


	@jquerify:
		precompiled: (data) ->
			return """
				   function (values, data) {
					   var $ = jQuery, result = $();
					   values = $.makeArray(values);
					   data = data || {};
					   for (var i=0; i < values.length; i++) {
						   var value = $.extend({}, values[i], data, {index: i});
						   var elem  = $((#{data})(value));
						   elem.data('item', value);
						   $.merge(result, elem);
					   }
					   return result;
				   };
				   """

		compiled: (data) ->
			data = data.replace(/\'/g, "\\'")
			data = data.replace(/\n/g, "' +\n'")
			data = data.replace(/[\s\+]+$/, '')
			return "(function() {\n$('#{data}');\n}).call(this);"


module.exports = Compiler