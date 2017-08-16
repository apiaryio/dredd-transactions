{deserialize} = require('../refract-serialization')


module.exports = (hrefVariablesElement) ->
  params = {}
  return params unless hrefVariablesElement

  hrefVariablesElement.forEach((valueElement, keyElement, memberElement) ->
    name = keyElement.toValue()
    params[name] =
      required: isRequired(memberElement)
      default: getDefaultValue(valueElement)
      example: getExampleValue(valueElement)
      values: getValues(valueElement)
  )
  return params


isRequired = (memberElement) ->
  attributesElement = memberElement.attributes
  return false unless attributesElement
  typeAttributesElement = attributesElement.get('typeAttributes')
  return false unless typeAttributesElement
  return typeAttributesElement.contains('required')


getExampleValue = (valueElement) ->
  value = valueElement.toValue()
  return value unless valueElement.element is 'enum'

  return undefined unless valueElement.attributes
  attributes = valueElement.attributes.toValue()

  try
    return attributes.samples[0][0]
  catch
    return value[0]


getDefaultValue = (valueElement) ->
  return undefined unless valueElement.attributes
  attributes = valueElement.attributes.toValue()

  if valueElement is 'enum' and attributes.default and attributes.default.length
    return attributes.default[0]
  return attributes.default


getValues = (valueElement) ->
  return [] unless valueElement.element is 'enum'
  return ({value} for value in valueElement.toValue())
