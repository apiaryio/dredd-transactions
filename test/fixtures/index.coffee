
fs = require('fs')
path = require('path')
zoo = require('swagger-zoo')


fromSwaggerZoo = (name) ->
  for feature in zoo.features()
    return feature.swagger if feature.name is name


fromFile = (filename) ->
  return fs.readFileSync(path.join(__dirname, filename)).toString()


FORMAT_NAMES =
  apiBlueprint: 'API Blueprint'
  swagger: 'Swagger'


# Fixture factory. Makes sure the fixtures are available both as an iterable
# array as well as name/source mapping.
fixture = (apiDescriptions) ->
  # The fixture is an array
  fix = (
    {format: FORMAT_NAMES[name], source} for own name, source of apiDescriptions
  )

  # At the same time, it is an object so we can access specific format as
  # an object property
  fix[name] = source for own name, source of apiDescriptions

  # And this is handy helper for tests
  fix.forEachDescribe = (fn) ->
    @forEach(({format, source}) ->
      describe(format, ->
        fn({format, source})
      ))

  return fix


# Collection of API description fixtures. To iterate over all available formats
# of specific fixture (e.g. `parserError`), use:
#
#     fixtures.parserError.forEach(({format, source}) ->
#       ...
#     )
#
# To do the same in tests:
#
#     fixtures.parserError.forEachDescribe(({format, source}) ->
#       ...
#     )
#
# To get source of specific format of a specific fixture directly, use:
#
#     source = fixtures.parserError.apiBlueprint
#
fixtures =
  # Supported by both API description formats
  empty: fixture(
    apiBlueprint: ''
    swagger: ''
  )
  ordinary: fixture(
    apiBlueprint: fromFile('./api-blueprint/ordinary.apib')
    swagger: fromSwaggerZoo('action')
  )
  parserError: fixture(
    apiBlueprint: fromFile('./api-blueprint/parser-error.apib')
    swagger: fromFile('./swagger/parser-error.yml')
  )
  parserWarning: fixture(
    apiBlueprint: fromFile('./api-blueprint/parser-warning.apib')
    swagger: fromSwaggerZoo('warnings')
  )
  uriExpansionAnnotation: fixture(
    apiBlueprint: fromFile('./api-blueprint/uri-expansion-annotation.apib')
    swagger: fromFile('./swagger/uri-expansion-annotation.yml')
  )
  uriValidationAnnotation: fixture(
    apiBlueprint: fromFile('./api-blueprint/uri-validation-annotation.apib')
    swagger: fromFile('./swagger/uri-validation-annotation.yml')
  )
  ambiguousParametersAnnotation: fixture(
    apiBlueprint: fromFile('./api-blueprint/ambiguous-parameters-annotation.apib')
    swagger: fromFile('./swagger/ambiguous-parameters-annotation.yml')
  )
  notSpecifiedInUriTemplateAnnotation: fixture(
    apiBlueprint: fromFile('./api-blueprint/not-specified-in-uri-template-annotation.apib')
    swagger: fromFile('./swagger/not-specified-in-uri-template-annotation.yml')
  )
  enumParameter: fixture(
    apiBlueprint: fromFile('./api-blueprint/enum-parameter.apib')
    swagger: fromFile('./swagger/enum-parameter.yml')
  )
  responseSchema: fixture(
    apiBlueprint: fromFile('./api-blueprint/response-schema.apib')
    swagger: fromSwaggerZoo('schema-reference')
  )
  parametersInheritance: fixture(
    apiBlueprint: fromFile('./api-blueprint/parameters-inheritance.apib')
    swagger: fromFile('./swagger/parameters-inheritance.yml')
  )
  preferDefault: fixture(
    apiBlueprint: fromFile('./api-blueprint/prefer-default.apib')
    swagger: fromFile('./swagger/prefer-default.yml')
  )
  httpHeaders: fixture(
    apiBlueprint: fromFile('./api-blueprint/http-headers.apib')
    swagger: fromFile('./swagger/http-headers.yml')
  )
  defaultRequired: fixture(
    apiBlueprint: fromFile('./api-blueprint/default-required.apib')
    swagger: fromFile('./swagger/default-required.yml')
  )
  exampleParameter: fixture(
    apiBlueprint: fromFile('./api-blueprint/example-parameter.apib')
    swagger: fromFile('./swagger/example-parameter.yml')
  )
  defaultRequiredBoolean: fixture(
    apiBlueprint: fromFile('./api-blueprint/default-required-boolean.apib')
    swagger: fromFile('./swagger/default-required-boolean.yml')
  )

  # Specific to API Blueprint
  unrecognizable: fixture(
    apiBlueprint: fromFile('./api-blueprint/unrecognizable.apib')
  )
  missingTitleAnnotation: fixture(
    apiBlueprint: fromFile('./api-blueprint/missing-title-annotation.apib')
  )
  multipleTransactionExamples: fixture(
    apiBlueprint: fromFile('./api-blueprint/multiple-transaction-examples.apib')
  )
  oneTransactionExample: fixture(
    apiBlueprint: fromFile('./api-blueprint/one-transaction-example.apib')
  )
  arbitraryAction: fixture(
    apiBlueprint: fromFile('./api-blueprint/arbitrary-action.apib')
  )
  withoutSections: fixture(
    apiBlueprint: fromFile('./api-blueprint/without-sections.apib')
  )
  preferSample: fixture(
    apiBlueprint: fromFile('./api-blueprint/prefer-sample.apib')
  )

  # Specific to Swagger
  produces: fixture(
    swagger: fromSwaggerZoo('produces-header')
  )
  consumes: fixture(
    swagger: fromFile('./swagger/consumes.yml')
  )
  multipleResponses: fixture(
    swagger: fromFile('./swagger/multiple-responses.yml')
  )


module.exports = fixtures
