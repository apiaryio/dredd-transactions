{parent} = require('../refract')
{deserialize} = require('../refract-serialization')

compileParams = require('./compile-params')
validateParams = require('./validate-params')
expandUriTemplate = require('./expand-uri-template')


module.exports = (refract, refractHttpRequest) ->
  annotations = {errors: [], warnings: []}
  cascade = getCascade(refract, refractHttpRequest)

  href = cascade
    .map((element) -> element.href?.toValue())
    .filter((href) -> !!href)
    .pop()

  # Support for 'httpRequest' parameters is experimental, so the element doesn't
  # have the '.hrefVariables' convenience property yet. If it's added in the
  # future, '.attributes.get('hrefVariables')' can be replaced with it.
  params = cascade
    .map((element) -> compileParams(element.attributes.get('hrefVariables')))
    .reduce(overrideParams, {})

  result = validateParams(params)
  component = 'parametersValidation'
  for error in result.errors
    annotations.errors.push({component, message: error})
  for warning in result.warnings
    annotations.warnings.push({component, message: warning})

  result = expandUriTemplate(href, params)
  component = 'uriTemplateExpansion'
  for error in result.errors
    annotations.errors.push({component, message: error})
  for warning in result.warnings
    annotations.warnings.push({component, message: warning})

  {uri: result.uri, annotations}


overrideParams = (params, paramsToOverride) ->
  params[name] = param for own name, param of paramsToOverride
  return params


# Temporary helper, until the interface of 'compileUri' changes to API Elements
getCascade = (refract, refractHttpRequest) ->
  refractResource = parent(refractHttpRequest, refract, {element: 'resource'})
  refractTransition = parent(refractHttpRequest, refract, {element: 'transition'})
  return [
    deserialize(refractResource)
    deserialize(refractTransition)
    deserialize(refractHttpRequest)
  ]
