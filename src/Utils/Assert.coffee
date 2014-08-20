class Assert
  _className: null
  _methodName: null
  constructor: ()->

  ###
  # setClassName( value : String )
  # Set the name of the classes for displaying error
  ###
  setClassName: (name)->
    if @isString(name)
      @_className = name
    else
      throw new TypeError("Assert.setClassName( String ) : Can only set string")

  ###
  # setName( value : String )
  # Store the name of actual method
  ###
  setName: (name)->
    if @isString(name)
      @_methodName = name
    else
      throw new TypeError("Assert.setName( String ) : Can only set string")

  ###
  # isUndefined( value : Any ) : Boolean
  # return if the value is undefined
  ###
  isUndefined: (value)->
    return typeof value == 'undefined'

  ###
  # isNull( value : Any ) : Boolean
  # return if the value is null
  ###
  isNull: (value)->
    return value == null

  ###
  # isBoolean( value : Any ) : Boolean
  # return if the value is an boolean
  ###
  isBoolean: (value)->
    return typeof value == 'boolean'

  ###
  # isString( value : Any ) : Boolean
  # return if the value is a string
  ###
  isString: (value)->
    return typeof value == 'string'

  ###
  # isFunction( value : Any ) : Boolean
  # return if the value is a function
  ###
  isFunction: (value)->
    return typeof value == 'function'

  ###
  # isObject( value : Any ) : Boolean
  # return if the value is an object
  ###
  isObject: (value)->
    return typeof value == 'object' and
    value isnt null and not Array.isArray(value)

  ###
  # isArray( value : Any ) : Boolean
  # return if the value is an array
  ###
  isArray: (value)->
    return Array.isArray(value)

  ###
  # isInt( value : Any ) : Boolean
  # return if the value is a int
  ###
  isInt: (value)->
    return Number.isInteger(value)

  ###
  # isFloat( value : Any ) : Boolean
  # return if the value is a float
  ###
  isFloat: (value)->
    return typeof value == 'number' and not Number.isInteger(value)

  ###
  # isAny( value : Any ) : Boolean
  # return if the value is a all except null or undefined
  ###
  isAny: (value)->
    return typeof value != 'undefined' and value != null

  ###
  # instanceOf( instance : Object, name : Function ) : Boolean
  # instanceOf( instance : Object, name : String ) : Boolean
  # return if the instance belongs to the name/class in second parameters
  ###
  instanceOf: (instance, name)->
    if not @isObject(instance)
      throw new TypeError('Utils.Assert.instanceOf: instance have to be an object')

    if @isFunction(name)
      return instance instanceof name
    else if @isString(name)
      regex  = /^function\s+(\w+)\s*\(.*\)/gi
      string = instance.constructor.toString()
      return regex.exec(string)[1] == name
    else
      throw new TypeError('Assert.instanceOf: name should be an String or an Function')

  ###
  # error( message : String)
  # throw error if the arguments are not of types of the second parameters
  ###
  error: (message)->
    if not @isString(message)
      throw new TypeError('Utils.Assert.error() : Message should be a String')
    else if not @_className? or not @_methodName?
      throw new TypeError("Assert.error() : couldn't display an error if setClassName() and setName() are not call earlier")
    else
      throw new Error("#{@_className}.#{@_methodName}() : #{message}")

  ###
  # params( args : Arguments, types : Array )
  # throw error if the arguments are not of types of the second parameters
  ###
  params: (args, types)->
    if not @isObject(args)
      throw new TypeError("#{@_name}: You should pass arguments to Assert.params")
      return false
    if not @isArray(types)
      throw new TypeError("#{@_name}: You should pass types to Assert.params")
      return false

    length = args.length ? Object.keys(args).length
    # If don't enought types are pass
    if types.length < length
      throw new TypeError("#{@_name}: You should pass the parameters of all the arguments")
      return false

    for type,i in types
      if not @is(args[i], type)
        throw new TypeError(@_getError(i, args, types))
    return true

  ###
  # is( value : Any, types : Array ) : Boolean
  # is( value : Any, types : String ) : Boolean
  # throw error if the value is not of types of the second parameters
  ###
  is: (value, types)->
    if not (@isString(types) or @isArray(types))
      throw new TypeError("Utils.Assert.is: types have to be an String or an Array")
      return false

    types = @_toArray(types)

    for type in types
      if @["is#{type}"]?
        return true if @["is#{type}"](value)
      else
        return true if @instanceOf(value, type)

    return false


  ###
  # _getError( key : Int, args : Arguments, types : Array ) : String
  # return a beautiful error
  ###
  _getError: (key, args, types)->
    if not @isInt(key) or not @isObject(args) or not @isArray(types)
      throw new TypeError("Utils.Assert._getError( key : Int, args : Arguments, types : Array )")


    error = ""
    if @isString(args[key])
      error += "'#{args[key]}'"
    else if @isObject(args[key])
      error += "object"
    else
      error += "#{args[key]}"

    error += " is not"

    type  = @_toArray(types[key])
    for t, i in type
      error += "," if i != 0 and i != type.length-1
      error += " or" if i == type.length-1 and i != 0
      error += " a #{t}"

    # Append all definition to the error
    for definition, i in @_getDefinitions(types)
      error += "\n"
      error += definition
    return error

  ###
  # _getDefinition( types : Array ) : Array
  # return all the definition of the current method/function
  ###
  _getDefinitions: (types)->
    if not @isArray(types)
      throw new TypeError('Utils.Assert._getDefinition: types need to be an array')
      return false

    definitions = []
    definitions.push("#{@_className}.#{@_methodName}(")
    for type, i in types
      if not @isArray(type)
        for definition, j in definitions
          definitions[j] += "," if i != 0
          definitions[j] += " #{type}"
      else
        size = type.length-definitions.length
        for j in [0..size-1]
          definitions.push(definitions[j])
        for t, j in type
          definitions[j] += "," if i != 0
          definitions[j] += " #{t}"

    for definition, i in definitions
      definitions[i] += " )"

    return definitions


  ###
  # _toArray( value : Any ) : Array
  # return an array in all the case
  ###
  _toArray: (value)->
    if @isArray(value)
      return value
    else
      result = []
      result.push(value)
      return result

`export { Assert }`
