uglify = require 'uglify-js'
cleanCss = require 'clean-css'
htmlMinifier = require 'html-minifier'

class Helpers


	@minify:
		js: (data) -> return uglify.minify(data, fromString: true).code
		css: (data) -> return cleanCss().minify(data)
		html: (data) ->
			data = htmlMinifier.minify(data,
				removeComments: true
				removeCommentsFromCDATA: true
				removeCDATASectionsFromCDATA: true
				collapseWhitespace: true
				collapseBooleanAttributes: true
				removeRedundantAttributes: true
				removeEmptyAttributes: true
			)
			return data


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


module.exports = Helpers