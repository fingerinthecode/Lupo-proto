angular.module('fileManager').
factory 'assert', () ->
  {
    tests: {
      isAnArray: (element) ->
        {}.toString.call(element) is '[object Array]'

      isAnObject: (element) ->
        {}.toString.call(element) is '[object Object]'
    }

    defined: (variable, varName, funcName) ->
      assert variable?, "<" + funcName + "> " + varName + " is not defined"

    array: (variable, varName, funcName) ->
      assert @tests.isAnArray(variable), "<" + funcName + "> " + varName + " is not an array"

    unchanged: (newVal, oldVal, newVarName, oldVarName, funcName) ->
      if oldVal?
        assert(newVal == oldVal, "<" + funcName + "> " + oldVarName + "/" + newVarName +
          " has changed (" + oldVal + "/" + newVal + ")")

    custom: (test) ->
      assert test
  }