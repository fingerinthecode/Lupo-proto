customMatchers = {
  toBeAnInstanceOf: ->
    return {
      compare: (actual, expected)->
        result = {}
        result.pass = (typeof actual is 'object' && actual instanceof expected)

        if result.pass
          result.message = "Expect #{actual} to not be an instance of #{expected}"
        else
          result.message = "Expect #{actual} to be an instance of #{expected}"

        return result
    }

  toBeAnArray: ->
    return {
      compare: (actual)->
        result = {}
        result.pass = Array.isArray(actual)

        if result.pass
          result.message = "Expect #{actual} to not be an array"
        else
          result.message = "Expect #{actual} to be an array but #{typeof actual}"

        return result
    }
}

beforeEach ->
  jasmine.addMatchers(customMatchers)
