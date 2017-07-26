{assert} = require 'chai'

validateParameters = require '../../src/validate-parameters'

describe 'validateParameters', ->

  it 'should return an object', ->
    params =
      name:
        description: 'Machine name'
        type: 'string'
        required: true
        example: 'waldo'
        default: ''
        values: []

    result = validateParameters params
    assert.isObject result

  describe 'when type is string and example is a parseable float', ->
    it 'should set no error', ->
      params =
        name:
          description: 'Machine name'
          type: 'string'
          required: true
          example: '1.1'
          default: null
          values: []

      result = validateParameters params
      message = result['errors'][0]
      assert.equal result['errors'].length, 0

  # Based on bug report:
  # https://github.com/apiaryio/dredd/issues/106
  describe 'when type is string and example is a string but starting with a number', ->
    it 'should set no error', ->
      params =
        name:
          description: 'Machine name'
          type: 'string'
          required: true
          example: '6f7c1245'
          default: null
          values: []

      result = validateParameters params

  describe 'when type is string and example is a not a parseable float', ->
    it 'should set no error', ->
      params =
        name:
          description: 'Machine name'
          type: 'string'
          required: true
          example: 'waldo'
          default: null
          values: []

      result = validateParameters params
      assert.equal result['errors'].length, 0

  describe 'when type is number and example is a string', ->
    it 'should set descriptive error', ->
      params =
        name:
          description: 'Machine name'
          type: 'number'
          required: true
          example: 'waldo'
          default: null
          values: []

      result = validateParameters params
      message = result['errors'][0]
      assert.include message, 'name'
      assert.include message, 'number'

  describe 'when type is number and example is a parseable float', ->
    it 'should set no error', ->
      params =
        name:
          description: 'Machine name'
          type: 'number'
          required: true
          example: '1.1'
          default: null
          values: []

      result = validateParameters params
      assert.equal result['errors'].length, 0

  describe 'when enum values are defined and example value is not one of enum values', ->
    it 'should set descirptive error', ->
      params =
        name:
          description: 'Machine name'
          type: 'string'
          required: true
          example: 'D'
          default: null
          values: [
            { "value": "A" },
            { "value": "B" },
            { "value": "C" }
          ]

      result = validateParameters params
      message = result['errors'][0]
      assert.include message, 'name'
      assert.include message, 'enum'

  describe 'when enum values are defined and example value is one of enum values', ->
    it 'should set no errors', ->
      params =
        name:
          description: 'Machine name'
          type: 'string'
          required: true
          example: 'A'
          default: null
          values: [
            { "value": "A" },
            { "value": "B" },
            { "value": "C" }
          ]

      result = validateParameters params
      assert.equal result['errors'].length, 0

  describe 'when type is boolean and example value is not parseable bool', ->
    it 'should set descirptive error', ->
      params =
        name:
          description: 'Machine name'
          type: 'boolean'
          required: true
          example: 'booboo'
          default: null
          values: []

      result = validateParameters params
      message = result['errors'][0]
      assert.include message, 'name'
      assert.include message, 'boolean'

  describe 'when type is boolean and example value is a parseable bool', ->
    it 'should set no error', ->
      params =
        name:
          description: 'Machine name'
          type: 'boolean'
          required: true
          example: 'true'
          default: null
          values: []

      result = validateParameters params
      assert.equal result['errors'].length, 0

  describe 'when parameter is required', () ->
    describe 'and example and default value are empty strings', () ->
      it 'should not set the error', () ->
        params =
          name:
            description: 'Machine name'
            type: 'string'
            required: true
            example: ''
            default: ''
            values: []

        result = validateParameters params
        assert.equal result['errors'].length, 0

    describe 'and example is empty string and default value is null', () ->
      it 'should not set the error', () ->
        params =
          name:
            description: 'Machine name'
            type: 'string'
            required: true
            example: ''
            default: null
            values: []

        result = validateParameters params
        assert.equal result['errors'].length, 0

    describe 'and example is null and default value is empty string', () ->
      it 'should not set the error', () ->
        params =
          name:
            description: 'Machine name'
            type: 'string'
            required: true
            example: null
            default: ''
            values: []

        result = validateParameters params
        assert.equal result['errors'].length, 0

    describe 'and example and default value are null', () ->
      it 'should set descirptive error', () ->
        params =
          name:
            description: 'Machine name'
            type: 'string'
            required: true
            example: null
            default: null
            values: []

        result = validateParameters params
        message = result['errors'][0]
        assert.include message, 'name'
        assert.include message, 'Required'

    describe 'and example and default value are undefined', () ->
      it 'should set descirptive error', () ->
        params =
          name:
            description: 'Machine name'
            type: 'string'
            required: true
            example: undefined
            default: undefined
            values: []

        result = validateParameters params
        message = result['errors'][0]
        assert.include message, 'name'
        assert.include message, 'Required'

    describe 'and default value is not empty and example value is empty', () ->
      it 'should not set the error', () ->
        params =
          name:
            description: 'Machine name'
            type: 'string'
            required: true
            example: null
            default: 'bagaboo'
            values: []

        result = validateParameters params
        assert.equal result['errors'].length, 0

    describe 'and example value is not empty and default value is empty', () ->
      it 'should not set the error', () ->
        params =
          name:
            description: 'Machine name'
            type: 'string'
            required: true
            example: 'booboo'
            default: null
            values: []

        result = validateParameters params
        assert.equal result['errors'].length, 0

  describe 'when parameter is not required', () ->
    describe 'and example and default value are empty', () ->
      it 'should not set the error', ->
        params =
          name:
            description: 'Machine name'
            type: 'string'
            required: false
            example: null
            default: null
            values: []

        result = validateParameters params
        assert.equal result['errors'].length, 0


    describe 'and default value is not empty and example value is empty', () ->
      it 'should not set the error', () ->
        params =
          name:
            description: 'Machine name'
            type: 'string'
            required: true
            example: null
            default: 'bagaboo'
            values: []

        result = validateParameters params
        assert.equal result['errors'].length, 0

    describe 'and example value is not empty and default value is empty', () ->
      it 'should not set the error', () ->
        params =
          name:
            description: 'Machine name'
            type: 'string'
            required: true
            example: 'booboo'
            default: null
            values: []

        result = validateParameters params
        assert.equal result['errors'].length, 0


    describe 'when type is boolean and example value is false', () ->
      it 'should not set the error', () ->
        params =
          name:
            description: 'Machine name'
            type: 'boolean'
            required: true
            example: 'false'
            default: null
            values: []

        result = validateParameters params
        assert.equal result['errors'].length, 0

    describe 'when type is boolean and default value is parseable bool and example value is empty string', () ->
      it 'should set descirptive error', () ->
        params =
          name:
            description: 'Machine name'
            type: 'boolean'
            required: true
            example: ''
            default: 'false'
            values: []

        result = validateParameters params
        message = result['errors'][0]
        assert.include message, 'name'
        assert.include message, 'boolean'

    describe 'when type is boolean and default value is parseable bool and example value is empty', () ->
      it 'should not set the error', () ->
        params =
          name:
            description: 'Machine name'
            type: 'boolean'
            required: true
            example: null
            default: 'false'
            values: []

        result = validateParameters params
        assert.equal result['errors'].length, 0

    describe 'when type is boolean and default value is not parseable bool and example value is empty', () ->
      it 'should not set the error', () ->
        params =
          name:
            description: 'Machine name'
            type: 'boolean'
            required: true
            example: null
            default: 'booooo'
            values: []

        result = validateParameters params
        message = result['errors'][0]
        assert.include message, 'name'
        assert.include message, 'boolean'
