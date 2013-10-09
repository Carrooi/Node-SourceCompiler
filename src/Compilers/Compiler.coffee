class Compiler


	isCachableWithDependencies: -> return false


	getMinifier: ->
		throw new Error 'Method getMinifier is not implemented.'


	parse: (data, options = {}) ->
		throw new Error 'Method parse is not implemented.'


	parseError: (error, path) ->
		throw new Error 'Method parseError is not implemented.'


module.exports = Compiler