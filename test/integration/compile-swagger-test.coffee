sinon = require('sinon')

fixtures = require('../fixtures')
{assert, compileFixture} = require('../utils')
createCompilationResultSchema = require('../schemas/compilation-result')


describe('compile() · Swagger', ->
  describe('causing a \'not specified in URI Template\' error', ->
    compilationResult = undefined

    beforeEach((done) ->
      compileFixture(fixtures.notSpecifiedInUriTemplateAnnotation.swagger, (args...) ->
        [err, compilationResult] = args
        done(err)
      )
    )

    it('produces one annotation and no transaction', ->
      assert.jsonSchema(compilationResult, createCompilationResultSchema(
        annotations: 1
        transactions: 0
      ))
    )
    context('the annotation', ->
      it('is error', ->
        assert.equal(compilationResult.annotations[0].type, 'error')
      )
      it('comes from the parser', ->
        assert.equal(compilationResult.annotations[0].component, 'apiDescriptionParser')
      )
      it('has message', ->
        assert.include(compilationResult.annotations[0].message.toLowerCase(), 'no corresponding')
        assert.include(compilationResult.annotations[0].message.toLowerCase(), 'in the path string')
      )
    )
  )

  describe('with \'produces\'', ->
    compilationResult = undefined

    beforeEach((done) ->
      compileFixture(fixtures.produces.swagger, (args...) ->
        [err, compilationResult] = args
        done(err)
      )
    )

    it('produces no annotations and two transactions', ->
      assert.jsonSchema(compilationResult, createCompilationResultSchema(
        annotations: 0
        transactions: 3
      ))
    )
    [
      {accept: 'application/json', contentType: 'application/json'}
      {accept: 'application/xml', contentType: 'application/xml'}
      {accept: 'application/json', contentType: 'text/plain'}
    ].forEach(({accept, contentType}, i) ->
      context("compiles a transaction for the '#{contentType}' media type", ->
        it('with expected request headers', ->
          assert.deepEqual(compilationResult.transactions[i].request.headers, {
            'Accept': {value: accept}
          })
        )
        it('with expected response headers', ->
          assert.deepEqual(compilationResult.transactions[i].response.headers, {
            'Content-Type': {value: contentType}
          })
        )
      )
    )
  )

  describe('with \'consumes\'', ->
    compilationResult = undefined

    beforeEach((done) ->
      compileFixture(fixtures.consumes.swagger, (args...) ->
        [err, compilationResult] = args
        done(err)
      )
    )

    it('produces no annotations and three transactions', ->
      assert.jsonSchema(compilationResult, createCompilationResultSchema(
        annotations: 0
        transactions: 3
      ))
    )
    [
      'application/json'
      'application/xml'
      'application/json'
    ].forEach((mediaType, i) ->
      context("compiles a transaction for the '#{mediaType}' media type", ->
        it('with expected request headers', ->
          assert.deepEqual(compilationResult.transactions[i].request.headers, {
            'Content-Type': {value: mediaType}
          })
        )
        it('with expected response headers', ->
          assert.deepEqual(compilationResult.transactions[i].response.headers, {})
        )
      )
    )
  )

  describe('with multiple responses', ->
    compilationResult = undefined
    filename = 'apiDescription.json'
    detectTransactionExampleNumbers = sinon.spy(require('../../src/detect-transaction-example-numbers'))
    expectedStatusCodes = [200, 200, 400, 400, 500, 500]

    beforeEach((done) ->
      stubs = {'./detect-transaction-example-numbers': detectTransactionExampleNumbers}
      compileFixture(fixtures.multipleResponses.swagger, {filename, stubs}, (args...) ->
        [err, compilationResult] = args
        done(err)
      )
    )

    it('does not call the detection of transaction examples', ->
      assert.isFalse(detectTransactionExampleNumbers.called)
    )
    it("produces no annotations and #{expectedStatusCodes.length} transactions", ->
      assert.jsonSchema(compilationResult, createCompilationResultSchema(
        annotations: 0
        transactions: expectedStatusCodes.length
      ))
    )

    for statusCode, i in expectedStatusCodes
      do (statusCode, i) ->
        context("origin of transaction ##{i + 1}", ->
          it('uses URI as resource name', ->
            assert.equal(compilationResult.transactions[i].origin.resourceName, '/honey')
          )

          it('uses method as action name', ->
            assert.equal(compilationResult.transactions[i].origin.actionName, 'GET')
          )

          it('uses status code and response\'s Content-Type as example name', ->
            contentType = if i % 2 then 'application/json' else 'application/xml'
            assert.equal(
              compilationResult.transactions[i].origin.exampleName,
              "#{statusCode} > #{contentType}"
            )
          )
        )
  )

  describe('with \'securityDefinitions\' and multiple responses', ->
    compilationResult = undefined

    beforeEach((done) ->
      compileFixture(fixtures.securityDefinitionsMultipleResponses.swagger, (args...) ->
        [err, compilationResult] = args
        done(err)
      )
    )

    it('produces no annotations and 2 transactions', ->
      assert.jsonSchema(compilationResult, createCompilationResultSchema(
        annotations: 0
        transactions: 2
      ))
    )
  )

  describe('with \'securityDefinitions\' containing transitions', ->
    compilationResult = undefined

    beforeEach((done) ->
      compileFixture(fixtures.securityDefinitionsTransitions.swagger, (args...) ->
        [err, compilationResult] = args
        done(err)
      )
    )

    it('produces no annotations and 1 transaction', ->
      assert.jsonSchema(compilationResult, createCompilationResultSchema(
        annotations: 0
        transactions: 1
      ))
    )
  )

  describe('without response schema', ->
    compilationResult = undefined

    beforeEach((done) ->
      compileFixture(fixtures.missingSchema.swagger, (args...) ->
        [err, compilationResult] = args
        done(err)
      )
    )

    it('produces no annotations and 1 transaction', ->
      assert.jsonSchema(compilationResult, createCompilationResultSchema(
        annotations: 0
        transactions: 1
      ))
    )
    it('produces response with schema', ->
      assert.ok(compilationResult.transactions[0].response.schema)
    )
    context('the schema', ->
      it('is JSON', ->
        schemaAsString = compilationResult.transactions[0].response.schema
        assert.doesNotThrow( -> JSON.parse(schemaAsString))
      )
      ['string', 42, ['array'], {name: 'object'}].forEach((value) ->
        it("considers anything as valid, e.g. #{JSON.stringify(value)}", ->
          schema = JSON.parse(compilationResult.transactions[0].response.schema)
          assert.jsonSchema(value, schema)
        )
      )
    )
  )
)
