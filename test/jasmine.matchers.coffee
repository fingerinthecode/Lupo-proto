customMatchers = {
  toBeAnInstanceOf: ->
    return {
      compare: (actual, expected)->
        result = {}
        result.pass = (typeof actual is 'object' && actual instanceof expected)

        if result.pass
          result.message = "Expect #{actual} to not be an instance of #{expected.name}"
        else
          result.message = "Expect #{actual} to be an instance of #{expected.name}"

        return result
    }

  toHaveALengthOf: ->
    return {
      compare: (actual, expected)->
        result = {}
        length = null
        if actual.length?
          length = actual.length
        else if actual instanceof Map or actual instanceof Set
          length = actual.size
        else if typeof actual == 'object'
          length = Object.keys(actual).length
        else if typeof actual == 'number'
          int    = Math.floor(test)
          length = int.toString().length
        else
          throw new Error("Impossible to have the length of #{actual}")

        result.pass = length == expected
        if result.pass
          result.message = "Expect #{actual} to not have a length of #{expected} but have #{length}"
        else
          result.message = "Expect #{actual} to have a length of #{expected} but have #{length}"
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
