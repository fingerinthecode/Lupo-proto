class Assert
  _name: null
  constructor: (name)->
    if typeof name != 'string'
      throw new TypeError('Assert need the name of the actual function/method to operate')
    else
    @_name = name

  ###
  # isUndefined( value : Any ) : Boolean
  # return : if the value is undefined
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
  # return if the value is a any
  ###
  isAny: (value)->
    return typeof value != 'undefined' and value != null

  ###
  # instanceOf( instance : Object, name : Function ) : Boolean
  # instanceOf( instance : Object, name : String ) : Boolean
  # return if the instance belongs to the name/class in second parameters
  ###
  instanceOf: (instance, name)->
    if @isFunction(name)
      return instance instanceof name
    else if @isString(name)
      regex  = /^function\s+(\w+)\s*\(.*\)/gi
      string = instance.constructor.toString()
      return regex.exec(string)[1] == name
    else
      throw new TypeError('Assert.instanceOf() only accept String or Object')

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

  ###
  # is( value : Any, types : Array ) : Boolean
  # is( value : Any, types : String ) : Boolean
  # throw error if the value is not of types of the second parameters
  ###
  is: (value, types)->
    types = @_toArray(types)

    for type in types
      if @hasOwnProperty("is#{type}")
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
      throw new TypeError("Assert._getError( key : Int, args : Arguments, types : Array )")

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
    for definition, i in @_getDefinitions()
      error += "\n"
      error += definition
    return error

  _getDefinitions: (types)->
    definitions = []
    definitions.push("#{@_name}(")
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


  _toArray: (value)->
    if @isArray(value)
      return value
    else
      result = []
      result.push(value)
      return result

export { Assert }
